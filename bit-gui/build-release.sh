#!/usr/bin/env bash
set -e

LEVEL="${1:-patch}"

case "$LEVEL" in
  patch|minor|major) ;;
  *)
    echo "Usage: $0 [patch|minor|major]  (default: patch)"
    exit 1
    ;;
esac

cd "$(dirname "$0")"

NEW_VERSION=$(npm version "$LEVEL" --no-git-tag-version)
echo "Bumped to $NEW_VERSION"

echo "Building frontend..."
npm run build

echo "Building Linux..."
npx electron-builder --linux
echo "Building Windows..."
npx electron-builder --win
echo "Building macOS..."
npx electron-builder --mac

echo ""
echo "=== Release artifacts ($NEW_VERSION) ==="
ls -1 release/
