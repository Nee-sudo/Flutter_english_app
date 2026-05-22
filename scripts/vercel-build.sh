#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"
FLUTTER_HOME="${FLUTTER_HOME:-/tmp/flutter}"

if [ ! -d "$FLUTTER_HOME/bin" ]; then
  echo "Installing Flutter ($FLUTTER_VERSION)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_VERSION" "$FLUTTER_HOME"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"
export PUB_CACHE="${PUB_CACHE:-$ROOT_DIR/.pub-cache}"

flutter --version
flutter config --enable-web --no-analytics
flutter precache --web
flutter pub get

# Same-origin API on Vercel: /api (serverless functions in /api folder)
# Override in Vercel env only if API is hosted elsewhere
API_BASE_URL="${API_BASE_URL:-/api}"
echo "Building Flutter web (API_BASE_URL=$API_BASE_URL)..."

flutter build web --release --dart-define="API_BASE_URL=$API_BASE_URL"

echo "Build complete: build/web"
