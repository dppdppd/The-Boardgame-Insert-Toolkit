#!/usr/bin/env bash

bit_current_version() {
    local lib="${1:-release/lib/boardgame_insert_toolkit_lib.4.scad}"
    sed -n 's/^VERSION = "\([^"]*\)";/\1/p' "$lib" | head -n 1
}

bit_version_file() {
    local version="$1"
    echo "release/lib/boardgame_insert_toolkit_lib.${version}.scad"
}

bit_version_gt() {
    local left="$1"
    local right="$2"
    local left_major
    local left_minor
    local left_patch
    local right_major
    local right_minor
    local right_patch

    IFS=. read -r left_major left_minor left_patch <<< "$left"
    IFS=. read -r right_major right_minor right_patch <<< "$right"

    (( left_major > right_major )) && return 0
    (( left_major < right_major )) && return 1
    (( left_minor > right_minor )) && return 0
    (( left_minor < right_minor )) && return 1
    (( left_patch > right_patch ))
}

bit_latest_versioned_version() {
    local latest=""
    local file
    local version

    for file in release/lib/boardgame_insert_toolkit_lib.[0-9]*.[0-9]*.[0-9]*.scad; do
        [[ -e "$file" ]] || continue
        version="${file#release/lib/boardgame_insert_toolkit_lib.}"
        version="${version%.scad}"
        if [[ -z "$latest" ]] || bit_version_gt "$version" "$latest"; then
            latest="$version"
        fi
    done

    echo "$latest"
}

bit_versioned_lib_matches() {
    local version="$1"
    local lib="${2:-release/lib/boardgame_insert_toolkit_lib.4.scad}"
    local versioned

    versioned="$(bit_version_file "$version")"
    [[ -f "$versioned" ]] && cmp -s "$lib" "$versioned"
}

bit_next_version() {
    local bump="${1:-patch}"
    local base="${2:-$(bit_current_version)}"
    local current
    local major
    local minor
    local patch

    current="$base"
    IFS=. read -r major minor patch <<< "$current"

    if [[ ! "$major" =~ ^[0-9]+$ || ! "$minor" =~ ^[0-9]+$ || ! "$patch" =~ ^[0-9]+$ ]]; then
        echo "Invalid current VERSION: $current" >&2
        return 1
    fi

    case "$bump" in
        patch)
            echo "${major}.${minor}.$((patch + 1))"
            ;;
        minor)
            echo "${major}.$((minor + 1)).0"
            ;;
        *)
            echo "Invalid version bump: $bump" >&2
            return 1
            ;;
    esac
}

bit_stamp_version() {
    local version="$1"
    local lib="${2:-release/lib/boardgame_insert_toolkit_lib.4.scad}"

    sed -i.bak "s/^VERSION = \"[^\"]*\";/VERSION = \"${version}\";/" "$lib"
    sed -i.bak "s|^ \* Version: .*| * Version: ${version}|" "$lib"
    rm -f "${lib}.bak"
}
