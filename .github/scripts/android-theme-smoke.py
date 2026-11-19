"""Exercise the signed APK on a clean Android emulator via the public Android UI."""
import argparse
from pathlib import Path
import re
import struct
import subprocess
import time
from xml.etree import ElementTree


PACKAGE = "com.adguard.trusttunnel.control"
ACTIVITY = PACKAGE + "/com.adguard.trusttunnel.MainActivity"
DARK = bytes.fromhex("10161dff")
LIGHT = bytes.fromhex("ffffffff")


def adb(*args):
    return subprocess.check_output(["adb", *args], timeout=35)


def start():
    adb("shell", "am", "start", "-W", "-n", ACTIVITY)


def check_surface(name, color, evidence):
    deadline = time.monotonic() + 65
    while time.monotonic() < deadline:
        activities = adb("shell", "dumpsys", "activity", "activities").decode(errors="replace")
        if not any(PACKAGE + "/" in line and "ResumedActivity" in line for line in activities.splitlines()):
            time.sleep(1)
            continue
        raw = adb("exec-out", "screencap")
        if len(raw) > 16:
            width, height, pixel_format = struct.unpack_from("<III", raw)
            if pixel_format in (1, 2) and raw.count(color) > width * height // 5:
                (evidence / (name + ".png")).write_bytes(adb("exec-out", "screencap", "-p"))
                print(name, width, height, flush=True)
                return
        time.sleep(1)
    (evidence / (name + "-failed.png")).write_bytes(adb("exec-out", "screencap", "-p"))
    raise RuntimeError("Expected application background in " + name)


def tap(label):
    deadline = time.monotonic() + 35
    labels = []
    while time.monotonic() < deadline:
        adb("shell", "uiautomator", "dump", "/sdcard/theme-window.xml")
        try:
            nodes = ElementTree.fromstring(adb("exec-out", "cat", "/sdcard/theme-window.xml"))
        except ElementTree.ParseError:
            continue
        labels = []
        for node in nodes.iter("node"):
            if node.get("package") != PACKAGE:
                continue
            parts = node.get("content-desc", "").splitlines() + node.get("text", "").splitlines()
            labels.extend(parts)
            if label not in parts:
                continue
            x1, y1, x2, y2 = map(int, re.findall(r'-?\d+', node.get("bounds", "")))
            adb("shell", "input", "tap", str((x1 + x2) // 2), str((y1 + y2) // 2))
            return
        time.sleep(1)
    raise RuntimeError(f"Could not locate {label!r}. Visible labels: {labels}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path)
    parser.add_argument("evidence", type=Path)
    args = parser.parse_args()
    args.evidence.mkdir(parents=True, exist_ok=True)
    print("Device ABIs:", adb("shell", "getprop", "ro.product.cpu.abilist").decode().strip(), flush=True)
    installed = subprocess.check_output(["adb", "install", "-r", str(args.apk)], timeout=120)
    print(installed.decode().strip(), flush=True)
    package = adb("shell", "dumpsys", "package", PACKAGE).decode()
    print(next(line.strip() for line in package.splitlines() if "versionCode=" in line), flush=True)
    adb("shell", "cmd", "uimode", "night", "no")
    start()
    check_surface("01-first-launch-light", LIGHT, args.evidence)
    pid = adb("shell", "pidof", PACKAGE).strip()
    tap("Settings")
    tap("Theme")
    tap("Dark")
    check_surface("02-manual-dark", DARK, args.evidence)
    if adb("shell", "pidof", PACKAGE).strip() != pid:
        raise RuntimeError("Theme selection restarted the application")
    adb("shell", "am", "force-stop", PACKAGE)
    start()
    check_surface("03-restored-dark", DARK, args.evidence)
    tap("Settings")
    tap("Theme")
    tap("System")
    check_surface("04-system-light", LIGHT, args.evidence)
    adb("shell", "cmd", "uimode", "night", "yes")
    check_surface("05-system-dark-foreground", DARK, args.evidence)
    tap("Theme")
    tap("Light")
    check_surface("06-manual-light-while-system-dark", LIGHT, args.evidence)
    tap("Theme")
    tap("System")
    check_surface("07-system-dark-restored", DARK, args.evidence)
    adb("shell", "input", "keyevent", "KEYCODE_HOME")
    adb("shell", "cmd", "uimode", "night", "no")
    start()
    check_surface("08-system-light-after-resume", LIGHT, args.evidence)


if __name__ == "__main__":
    main()
