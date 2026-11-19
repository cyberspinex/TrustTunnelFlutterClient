"""Exercise the release APK through Android 15 SystemUI on a disposable Google APIs emulator."""
import argparse
import importlib.util
import re
import sqlite3
import subprocess
import tempfile
import time
from pathlib import Path
from xml.etree import ElementTree as ET

spec = importlib.util.spec_from_file_location("theme", Path(__file__).with_name("android-theme-smoke.py"))
theme = importlib.util.module_from_spec(spec)
spec.loader.exec_module(theme)
PKG = theme.PACKAGE
COMPONENT = PKG + "/com.adguard.trusttunnel.vpn_plugin.TrustTunnelTileService"
DB = "/data/user/0/" + PKG + "/app_flutter/vpn_oss_db.sqlite"
NAME = "TrustTunnel NAVQS"


def adb(*args, check=True, timeout=40):
    return subprocess.run(["adb", *map(str, args)], capture_output=True, check=check, timeout=timeout)


def shell(*args):
    return adb("shell", *args).stdout.decode(errors="replace").strip()


def until(read, timeout, label):
    end = time.monotonic() + timeout
    last = None
    while time.monotonic() < end:
        last = read()
        if last:
            return last
        time.sleep(0.6)
    raise AssertionError("Timed out waiting for " + label)


def cold():
    shell("cmd", "statusbar", "collapse")
    shell("input", "keyevent", "KEYCODE_HOME")
    time.sleep(0.7)
    shell("am", "kill", PKG)
    pid = adb("shell", "pidof", PKG, check=False).stdout.decode().split()
    if pid:
        shell("kill", "-9", *pid)
    until(lambda: not adb("shell", "pidof", PKG, check=False).stdout.strip(), 15, "a cold process")


def fixture(rows=None):
    """Seed only the offline disposable emulator database. Preserve UID, mode and SELinux label."""
    with tempfile.TemporaryDirectory() as directory:
        dest = Path(directory) / "fixture.sqlite"
        adb("pull", DB, dest)
        wal = dest.with_name(dest.name + "-wal")
        if adb("shell", "test", "-s", DB + "-wal", check=False).returncode == 0:
            adb("pull", DB + "-wal", wal)
        with sqlite3.connect(dest) as connection:
            if rows is not None:
                connection.execute("delete from servers")
                connection.executemany(
                    "insert into servers (name, selected, domain, ip_address, login, password, vpn_protocol_id,"
                    " routing_profile_id) values (?, ?, ?, '127.0.0.1:1', 'fixture', 'fixture', 2, 0)", rows)
            names = list(connection.execute("select name from servers order by id"))
        if rows is not None:
            connection.execute("pragma wal_checkpoint(truncate)")
            connection.close()
            adb("push", dest, "/data/local/tmp/navqs-fixture.sqlite")
            shell("rm", "-f", DB + "-wal", DB + "-shm")
            shell("cat /data/local/tmp/navqs-fixture.sqlite > " + DB)
            shell("rm", "/data/local/tmp/navqs-fixture.sqlite")
        else:
            connection.close()
        return [n for n, in names]


def nodes():
    result = adb("shell", "uiautomator", "dump", "/sdcard/navqs-window.xml", check=False, timeout=20)
    if result.returncode or b"dumped" not in result.stdout.lower():
        return []
    try:
        return list(ET.fromstring(adb("exec-out", "cat", "/sdcard/navqs-window.xml").stdout).iter("node"))
    except ET.ParseError:
        return []


def words(node):
    return " ".join(node.get(k, "") for k in ("text", "content-desc", "state-description"))


def press(node):
    x1, y1, x2, y2 = map(int, re.findall(r"-?\d+", node.get("bounds")))
    shell("input", "tap", (x1 + x2) // 2, (y1 + y2) // 2)


def shade(statuses):
    shell("cmd", "statusbar", "expand-settings")
    def visible():
        screen = [n for n in nodes() if n.get("package") == "com.android.systemui"]
        tile = next((n for n in screen if NAME in words(n)), None)
        if tile is None:
            return None
        contents = " ".join(words(n) for n in screen)
        return next(((s, tile) for s in statuses if s.lower() in contents.lower()), None)
    return until(visible, 55, "SystemUI tile showing " + " / ".join(statuses))


def tap_tile(*statuses):
    _, node = shade(statuses)
    press(node)


def consent(button):
    def find_button():
        return next((n for n in nodes() if n.get("package") == "com.android.vpndialogs" and
                     n.get("resource-id", "").endswith("/" + button)), None)
    # ElementTree nodes have false truth value when they have no children.
    answer = until(lambda: [n] if (n := find_button()) is not None else None, 45, "Android VPN consent")
    press(answer[0])


def clear_service_evidence():
    adb("logcat", "-b", "events", "-c")


def service_started():
    component = PKG + "/com.adguard.trusttunnel.VpnService"
    events = adb("logcat", "-b", "events", "-d", "-s", "am_create_service").stdout.decode(errors="replace")
    if component in events or component in shell("dumpsys", "activity", "services", PKG):
        return True
    return False


def checkpoint(message):
    print("PASS", message, flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path)
    parser.add_argument("evidence", type=Path)
    parser.add_argument("--baseline", type=Path)
    args = parser.parse_args()
    adb("root")
    adb("wait-for-device")
    if shell("id", "-u") != "0":
        raise RuntimeError("Fixture setup requires a disposable userdebug emulator")
    shell("cmd", "uimode", "night", "no")
    adb("install", "-r", args.baseline or args.apk, timeout=120)
    theme.start()
    theme.check_surface("tile-initial-launch", theme.LIGHT, args.evidence)
    until(lambda: adb("shell", "test", "-s", DB, check=False).returncode == 0, 25, "profile database")
    if args.baseline:
        assert "versionCode=2011 " in shell("dumpsys", "package", PKG)
        theme.tap("Settings")
        theme.tap("Theme")
        theme.tap("Dark")
        theme.check_surface("tile-baseline-dark", theme.DARK, args.evidence)
        cold()
        fixture([("Upgrade fixture", 1, "vpn.example.org")])
        adb("install", "-r", args.apk, timeout=120)
        assert fixture() == ["Upgrade fixture"]
        theme.start()
        theme.check_surface("tile-upgraded-dark", theme.DARK, args.evidence)
        checkpoint("Installed over 2011 and retained the profile and dark theme")
    cold()
    fixture([])
    shell("settings", "put", "secure", "sysui_qs_tiles", "custom\\(" + COMPONENT + "\\)")
    shell("cmd", "statusbar", "add-tile", COMPONENT)
    tap_tile("Disconnected")
    time.sleep(3)
    shade(["Add a server in the app"])
    checkpoint("Cold tile reports an empty server list")
    cold()
    fixture([("First", 0, "one.example.org"), ("Second", 0, "two.example.org")])
    tap_tile("Disconnected")
    time.sleep(3)
    shade(["Choose a server in the app"])
    checkpoint("Multiple profiles require an explicit choice")
    cold()
    fixture([("First", 0, "one.example.org"), ("Broken", 1, "")])
    tap_tile("Disconnected")
    time.sleep(3)
    shade(["Check the server settings in the app"])
    checkpoint("Invalid selected server produces an actionable error")
    cold()
    fixture([("Sole", 0, "vpn.example.org")])
    tap_tile("Disconnected")
    consent("button2")
    shade(["VPN permission declined"])
    checkpoint("System consent denied and the tile is ready to retry")
    clear_service_evidence()
    tap_tile("VPN permission declined")
    consent("button1")
    time.sleep(1.0)
    statuses = ["Connection failed", "Waiting to reconnect", "Reconnecting", "Waiting for network", "Connecting"]
    status, tile = shade(statuses)
    if status != "Connection failed":
        press(tile)
        shade(["Disconnected", "Connection failed"])
    until(service_started, 20, "Android to record creation of the native VPN service")
    checkpoint("System consent approval starts the native VPN path; unreachable loopback endpoint stays inactive")
    if "allow" not in shell("cmd", "appops", "get", PKG, "ACTIVATE_VPN"):
        raise AssertionError("Expected Android VPN authorization")
    checkpoint("Approval persisted in Android")
    cold()
    clear_service_evidence()
    shell("cmd", "statusbar", "expand-settings")
    tap_tile("Disconnected")
    status, tile = shade(statuses)
    if status != "Connection failed":
        press(tile)
        shade(["Disconnected", "Connection failed"])
    until(service_started, 20, "a native service start from a cold process")
    checkpoint("Cold start with previously granted permission and closed main UI")
    shell("cmd", "statusbar", "collapse")
    theme.start()
    theme.check_surface("tile-main-ui-after-cold-start", theme.DARK if args.baseline else theme.LIGHT, args.evidence)
    checkpoint("Main activity can reopen after headless profile reads")
    shell("input", "keyevent", "KEYCODE_HOME")
    adb("reboot")
    adb("wait-for-device", timeout=110)
    until(lambda: shell("getprop", "sys.boot_completed") == "1", 120, "Android reboot")
    shell("input", "keyevent", "KEYCODE_WAKEUP")
    shell("wm", "dismiss-keyguard")
    tap_tile("Disconnected")
    status, tile = shade(statuses)
    if status != "Connection failed":
        press(tile)
        shade(["Disconnected", "Connection failed"])
    until(service_started, 20, "a native service start after reboot")
    checkpoint("Tile can start after reboot and first unlock without opening TrustTunnel")


if __name__ == "__main__":
    main()
