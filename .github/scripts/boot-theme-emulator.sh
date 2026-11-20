#!/usr/bin/env bash
set -euo pipefail
image='system-images;android-35;google_apis;x86_64'
cli="$ANDROID_HOME/cmdline-tools/latest/bin"
emulator="$ANDROID_HOME/emulator/emulator"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export ANDROID_AVD_HOME="$RUNNER_TEMP/theme-avd"
export ANDROID_SERIAL=emulator-5554
mkdir -p "$ANDROID_AVD_HOME" theme-screens
"$cli/sdkmanager" --install "platform-tools" "emulator" "$image"
# Keep the runner's emulator consistent with the accepted Android 15 baseline.
if ! "$emulator" -version | grep -F '37.2.13.0' >/dev/null; then
  archive="$RUNNER_TEMP/navqs-emulator-16740729.zip"
  curl --fail --silent --show-error --location --retry 3 \
    https://dl.google.com/android/repository/emulator-linux_x64-16740729.zip -o "$archive"
  echo "cbc7c3cfb83220b8a0f9c513fdab557712e74d339ec19ddffa43f23350ae9bdd  $archive" | sha256sum -c -
  unzip -qo "$archive" -d "$RUNNER_TEMP/navqs-emulator-16740729"
  emulator="$RUNNER_TEMP/navqs-emulator-16740729/emulator/emulator"
fi
export ANDROID_SDK_ROOT="$ANDROID_HOME"
"$emulator" -version
printf 'no\n' | "$cli/avdmanager" create avd --name theme-test --package "$image" --device pixel_2
sudo setfacl -m "u:$(id -un):rw" /dev/kvm
"$emulator" -accel-check
"$emulator" -list-avds
df -h "$ANDROID_AVD_HOME"

# The default userdata image can exceed the space available on hosted runners.
cfg="$ANDROID_AVD_HOME/theme-test.avd/config.ini"
sed -i '/^disk.dataPartition.size=/d' "$cfg"
echo 'disk.dataPartition.size=2048M' >> "$cfg"
adb start-server
"$emulator" -avd theme-test -port 5554 -no-window -no-audio -no-metrics -no-snapshot \
  -no-boot-anim -gpu software -camera-front none -camera-back none -cores 2 -memory 2048 \
  >theme-screens/emulator.log 2>&1 &
pid=$!
cleanup() {
  status=$?
  if (( status != 0 )); then
    tail -80 theme-screens/emulator.log
    adb devices -l
    if [[ "$(timeout 8 adb get-state 2>/dev/null || true)" == device ]]; then
      timeout 10 adb logcat -d -t 1000 >theme-screens/logcat.txt || true
      timeout 10 adb exec-out screencap -p >theme-screens/failure.png || true
    fi
  fi
  kill "$pid" 2>/dev/null || true
}
trap cleanup EXIT
deadline=$((SECONDS + 480))
until [[ "$(timeout 8 adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)" == 1 ]]; do
  if ! kill -0 "$pid" 2>/dev/null; then
    echo 'Android emulator exited before the guest booted'
    exit 1
  fi
  if (( SECONDS >= deadline )); then
    echo 'Android guest did not finish booting within eight minutes'
    exit 1
  fi
  sleep 3
done
adb shell input keyevent KEYCODE_WAKEUP
adb shell wm dismiss-keyguard
apk=$(find signed -name '*.apk' | sort -V | tail -1)
sha256sum "$apk"
if [[ "${GITHUB_REF_NAME:-}" == android/quick-settings ]]; then
  baseline_args=()
  if [[ -f baseline/TrustTunnel-NAVQS-arm64-11.apk ]]; then
    baseline_args+=(--baseline baseline/TrustTunnel-NAVQS-arm64-11.apk)
  fi
  python3 .github/scripts/android-tile-smoke.py "$apk" theme-screens "${baseline_args[@]}"
  adb shell pm clear com.adguard.trusttunnel.control
fi
python3 .github/scripts/android-theme-smoke.py "$apk" theme-screens
