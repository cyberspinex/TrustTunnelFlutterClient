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
unzip -p "$aar" classes.jar > "$work/classes.jar"
unzip -Z1 "$work/classes.jar" > "$work/classes"
grep -Fx 'com/adguard/trusttunnel/AppVpnStore.class' "$work/classes"
printf 'Android adapter source %s\n' "$revision"
sha256sum "$aar"
