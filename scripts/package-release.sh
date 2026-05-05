#!/usr/bin/env bash
# Create the version-locked BIT library file used for shipping.
#
# The development file remains release/lib/boardgame_insert_toolkit_lib.4.scad.
# Use patch releases for bug fixes with no user-facing impact. Use minor
# releases for user-facing features.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
. "$ROOT_DIR/scripts/version-common.sh"

LIB="release/lib/boardgame_insert_toolkit_lib.4.scad"
SMOKE=true
BUMP="patch"

usage() {
    cat <<'EOF'
Usage: scripts/package-release.sh [--patch|--minor] [--no-smoke]

Creates:
  release/lib/boardgame_insert_toolkit_lib.<VERSION>.scad

Version guidance:
  --patch   Bug fixes or internal changes with no user-facing impact.
  --minor   User-facing features.

If the current development library already matches its full-version file, this
script refreshes shipped includes without bumping again.

Options:
  --patch      Increment the patch number. Default.
  --minor      Increment the minor number and reset patch to 0.
  --no-smoke   Skip the OpenSCAD compile checks.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --patch)
            BUMP="patch"
            shift
            ;;
        --minor)
            BUMP="minor"
            shift
            ;;
        --no-smoke)
            SMOKE=false
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ ! -f "$LIB" ]]; then
    echo "Missing library: $LIB" >&2
    exit 1
fi

CURRENT_VERSION="$(bit_current_version "$LIB")"
LATEST_VERSION="$(bit_latest_versioned_version)"

if bit_versioned_lib_matches "$CURRENT_VERSION" "$LIB"; then
    VERSION="$CURRENT_VERSION"
    RELEASE_MODE="refresh"
elif [[ -n "$LATEST_VERSION" ]]; then
    REQUESTED_VERSION="$(bit_next_version "$BUMP" "$LATEST_VERSION")"
    if bit_version_gt "$CURRENT_VERSION" "$REQUESTED_VERSION"; then
        VERSION="$CURRENT_VERSION"
        RELEASE_MODE="current"
    else
        VERSION="$REQUESTED_VERSION"
        RELEASE_MODE="$BUMP"
    fi
else
    VERSION="$(bit_next_version "$BUMP" "$CURRENT_VERSION")"
    RELEASE_MODE="$BUMP"
fi

VERSIONED_LIB="release/lib/boardgame_insert_toolkit_lib.${VERSION}.scad"
VERSIONED_BASENAME="$(basename "$VERSIONED_LIB")"
TEMPLATE_FILES=(
    "release/my_designs/starter.scad"
    "release/my_designs/examples.4.scad"
)
SMOKE_FILES=(
    "release/my_designs/starter.scad"
    "release/my_designs/examples.4.scad"
)

echo "Packaging BIT ${VERSION} (${RELEASE_MODE})"

bit_stamp_version "$VERSION" "$LIB"

cp "$LIB" "$VERSIONED_LIB"

for file in "${TEMPLATE_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        sed -i.bak -E \
            "s|include <\\.\\./lib/boardgame_insert_toolkit_lib\\.[0-9][0-9.]*\\.scad>;|include <../lib/${VERSIONED_BASENAME}>;|" \
            "$file"
        rm -f "${file}.bak"
    fi
done

if [[ "$SMOKE" == true ]]; then
    if ! command -v openscad >/dev/null 2>&1; then
        echo "openscad not found; rerun with --no-smoke to skip the compile check" >&2
        exit 1
    fi

    for smoke_file in "${SMOKE_FILES[@]}"; do
        if [[ -f "$smoke_file" ]]; then
            SMOKE_OUT="$(mktemp /tmp/bit_release_smoke_XXXXXX.csg)"
            SMOKE_LOG="$(mktemp /tmp/bit_release_smoke_XXXXXX.log)"
            if ! openscad -o "$SMOKE_OUT" "$smoke_file" >"$SMOKE_LOG" 2>&1; then
                cat "$SMOKE_LOG" >&2
                rm -f "$SMOKE_OUT" "$SMOKE_LOG"
                exit 1
            fi
            rm -f "$SMOKE_OUT" "$SMOKE_LOG"
        fi
    done
fi

echo "Wrote $VERSIONED_LIB"
echo "Updated shipped includes to $VERSIONED_BASENAME"
