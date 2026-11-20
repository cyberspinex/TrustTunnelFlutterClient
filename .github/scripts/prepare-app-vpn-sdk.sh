#!/usr/bin/env bash
# Build the checked-in Android adapter revision into a repository private to this checkout.
set -euo pipefail
: "${GPR_KEY:?Provide a GitHub token with read:packages for the original Android AAR}"
project=$(cd "$(dirname "$0")/../.." && pwd)
revision=$(cat "$project/android/app-vpn-sdk.rev")
[[ "$revision" =~ ^[0-9a-f]{40}$ ]]
sdk_version="1.3.0-rc.3-navqs.$revision"
repository="$project/android/.navqs-sdk"
work=$(mktemp -d "${RUNNER_TEMP:-/tmp}/navqs-sdk.XXXXXXXX")
trap 'rm -rf -- "$work"' EXIT
git init -q "$work/client"
git -C "$work/client" fetch --quiet --no-tags --depth=1 https://github.com/cyberspinex/TrustTunnelClient.git "$revision"
git -C "$work/client" checkout --quiet --detach FETCH_HEAD
test "$(git -C "$work/client" rev-parse HEAD)" = "$revision"

# Only the native engine is reused; all Java/Kotlin code is compiled from the fork.
artifact=trusttunnel-client-android
base=1.3.0-rc.3
url="https://maven.pkg.github.com/TrustTunnel/TrustTunnelClient/com/adguard/trusttunnel/$artifact/$base/$artifact-$base.aar"
curl --fail --silent --show-error --location --retry 3 --connect-timeout 20 --max-time 300 \
  --user "${GITHUB_ACTOR:-github}:$GPR_KEY" "$url" -o "$work/base.aar"
mkdir -p "$work/jni/arm64-v8a"
jni="arm64-v8a/libtrusttunnel_android.so"
unzip -p "$work/base.aar" "jni/$jni" > "$work/jni/$jni"
test -s "$work/jni/$jni"
adapter="$work/client/platform/android"
printf '%s\n' "$revision" > "$adapter/lib/src/main/assets/navqs-app-vpn-sdk-revision"
(cd "$adapter" && ./gradlew --console=plain :lib:publishReleasePublicationToMavenLocal \
  "-PttClientVersion=$sdk_version" "-PttPrebuiltJniDir=$work/jni" "-Dmaven.repo.local=$repository")
aar="$repository/com/adguard/trusttunnel/$artifact/$sdk_version/$artifact-$sdk_version.aar"
test "$(unzip -p "$aar" assets/navqs-app-vpn-sdk-revision)" = "$revision"
if [[ "${RUN_APP_VPN_TESTS:-}" == true ]]; then
  image='system-images;android-35;google_apis;x86_64'
  "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --install "platform-tools" "emulator" "$image"
  export ANDROID_AVD_HOME="$work/avd" ANDROID_SERIAL=emulator-5554
  export PATH="$ANDROID_HOME/platform-tools:$PATH"
  mkdir -p "$ANDROID_AVD_HOME"
  printf 'no\n' | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd \
    --name app-vpn-test --package "$image" --device pixel_2
  sudo setfacl -m "u:$(id -un):rw" /dev/kvm
  "$ANDROID_HOME/emulator/emulator" -avd app-vpn-test -port 5554 -no-window -no-audio \
    -no-snapshot -no-boot-anim -gpu software -cores 2 -memory 2048 > "$work/emulator.log" 2>&1 &
  emulator_pid=$!
  deadline=$((SECONDS + 480))
  until [[ "$(timeout 8 adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)" == 1 ]]; do
    if ! kill -0 "$emulator_pid" 2>/dev/null || (( SECONDS >= deadline )); then
      tail -80 "$work/emulator.log"
      exit 1
    fi
    sleep 3
  done
  (cd "$adapter" && ./gradlew --console=plain :lib:connectedDebugAndroidTest \
    "-PttPrebuiltJniDir=$work/jni")
  adb emu kill
  wait "$emulator_pid" || true
fi
unzip -p "$aar" classes.jar > "$work/classes.jar"
unzip -Z1 "$work/classes.jar" > "$work/classes"
grep -Fx 'com/adguard/trusttunnel/AppVpnStore.class' "$work/classes"
printf 'Android adapter source %s\n' "$revision"
sha256sum "$aar"
