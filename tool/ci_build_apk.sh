#!/usr/bin/env bash
# Dipanggil semantic-release (prepareCmd) di CI setelah versi rilis berikutnya ditentukan.
#   bash tool/ci_build_apk.sh <X.Y.Z> [build-number]
# Menulis `version: X.Y.Z+N` ke pubspec.yaml (hanya di runner, tidak di-commit), lalu build APK
# dan menamainya dist/Claymo-vX.Y.Z-release.apk.
set -euo pipefail

VERSION="${1:?Pemakaian: ci_build_apk.sh <X.Y.Z> [build-number]}"
cd "$(dirname "$0")/.."

# Tanpa argumen ke-2, build number = jumlah commit (git rev-list --count HEAD).
bump_args=(--set "$VERSION")
if [ -n "${2:-}" ]; then bump_args+=(--build-number "$2"); fi
dart run tool/version_bumper.dart "${bump_args[@]}"

BUILD_NUMBER="$(sed -n 's/^version:[[:space:]]*[0-9.]*+\([0-9]*\).*$/\1/p' pubspec.yaml | tr -d '\r')"
[ -n "$BUILD_NUMBER" ] || { echo "Build number tidak terbaca dari pubspec.yaml" >&2; exit 1; }

flutter pub get
flutter gen-l10n
flutter build apk --release --build-name="$VERSION" --build-number="$BUILD_NUMBER"

mkdir -p dist
cp build/app/outputs/flutter-apk/app-release.apk "dist/Claymo-v${VERSION}-release.apk"
echo "APK: dist/Claymo-v${VERSION}-release.apk (versi ${VERSION}+${BUILD_NUMBER})"
