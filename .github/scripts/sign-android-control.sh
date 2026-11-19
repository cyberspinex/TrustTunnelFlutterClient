#!/usr/bin/env bash
set -euo pipefail
shopt -s failglob
: "${CONTROL_SIGNING_PEM:?Set the TRUSTTUNNEL_CONTROL_SIGNING_PEM repository secret before signing}"
umask 077

input_dir=$1
output_dir=$2
sdk_tools="$ANDROID_HOME/build-tools/36.0.0"
expected_cert=17e7dd89e8323447136cc9439e2157f5efb6218b52848679d0a09c1f627c3454
key_dir=$(mktemp -d "${RUNNER_TEMP:-/tmp}/control-key.XXXXXXXX")
trap 'rm -rf -- "$key_dir"' EXIT
printf '%s\n' "$CONTROL_SIGNING_PEM" > "$key_dir/bundle.pem"
unset CONTROL_SIGNING_PEM
openssl pkcs8 -topk8 -nocrypt -in "$key_dir/bundle.pem" -outform DER -out "$key_dir/key.der"
openssl x509 -in "$key_dir/bundle.pem" -outform DER -out "$key_dir/cert.der"
printf '%s  %s\n' "$expected_cert" "$key_dir/cert.der" | sha256sum --check --status

mkdir -p "$output_dir"
for input in "$input_dir"/TrustTunnel-NAVQS-arm64-*.apk; do
  output="$output_dir/$(basename "$input")"
  "$sdk_tools/zipalign" -f -P 16 4 "$input" "$key_dir/aligned.apk"
  "$sdk_tools/apksigner" sign --key "$key_dir/key.der" --cert "$key_dir/cert.der" \
    --v4-signing-enabled false --out "$output" "$key_dir/aligned.apk"
  "$sdk_tools/apksigner" verify --verbose --print-certs "$output" > "$key_dir/signature"
  grep -Fx "Signer #1 certificate SHA-256 digest: $expected_cert" "$key_dir/signature"
  grep -Fx 'Verified using v2 scheme (APK Signature Scheme v2): true' "$key_dir/signature"
  "$sdk_tools/zipalign" -c -P 16 4 "$output"
done
(cd "$output_dir" && sha256sum TrustTunnel-NAVQS-arm64-*.apk > SHA256SUMS)
