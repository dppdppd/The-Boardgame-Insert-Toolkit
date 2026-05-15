#!/usr/bin/env bash
#
# Compare normalized OpenSCAD CSG output for existing v4 tests against a git
# baseline. This catches unintended CSG tree changes before committing while
# ignoring no-op group(), preview color(), and identity transform wrappers that
# OpenSCAD may serialize differently.
#
# Usage:
#   tests/csg_regression.sh
#   tests/csg_regression.sh --baseline HEAD~1
#   tests/csg_regression.sh test_box_minimal test_lid_basic

set -euo pipefail

BASELINE_REF="HEAD"
CSG_TIMEOUT=30
KEEP_OUTPUT=false
TESTS=()

usage() {
    echo "Usage: $0 [OPTIONS] [test_name ...]"
    echo ""
    echo "Options:"
    echo "  --baseline REF    Git ref to compare against (default: HEAD)"
    echo "  --csg-timeout N   Per-test CSG timeout in seconds (default: 30)"
    echo "  --keep-output     Keep generated CSG and diff files even on success"
    echo "  --help            Show this help"
    echo ""
    echo "Arguments:"
    echo "  test_name         One or more test names without .scad; defaults to all"
    echo "                    baseline-tracked tests/v4/scad/test_*.scad files"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --baseline)
            BASELINE_REF="$2"
            shift 2
            ;;
        --csg-timeout)
            CSG_TIMEOUT="$2"
            shift 2
            ;;
        --keep-output)
            KEEP_OUTPUT=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            TESTS+=("$1")
            shift
            ;;
    esac
done

if ! command -v git >/dev/null 2>&1; then
    echo "FATAL: git not found in PATH"
    exit 1
fi

if ! command -v openscad >/dev/null 2>&1; then
    echo "FATAL: openscad not found in PATH"
    exit 1
fi

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Git runs hooks with repository-local environment variables such as
# GIT_INDEX_FILE. Nested git commands for the temporary baseline worktree must
# use the normal repository context instead of inheriting the hook index.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX

if ! git rev-parse --verify "${BASELINE_REF}^{commit}" >/dev/null 2>&1; then
    echo "FATAL: baseline ref is not a commit: $BASELINE_REF"
    exit 1
fi

BASELINE_TREE="$(mktemp -d /tmp/bit_csg_baseline.XXXXXX)"
OUT_DIR="$(mktemp -d /tmp/bit_csg_regression.XXXXXX)"
DIFF_DIR="$OUT_DIR/diffs"
mkdir -p "$DIFF_DIR"

FAIL=0
cleanup() {
    git worktree remove --force "$BASELINE_TREE" >/dev/null 2>&1 || true
    if [[ "$KEEP_OUTPUT" != true && "${FAIL:-0}" -eq 0 ]]; then
        rm -rf "$OUT_DIR"
    fi
}
trap cleanup EXIT

git worktree add --detach "$BASELINE_TREE" "$BASELINE_REF" >/dev/null 2>&1

normalize_csg() {
    awk '
        function trim(s) {
            sub(/^[[:space:]]+/, "", s)
            sub(/[[:space:]]+$/, "", s)
            return s
        }
        function push(kind) {
            stack[++depth] = kind
        }
        function pop() {
            if (depth > 0) {
                depth--
            }
        }
        {
            sub(/\r$/, "")
            line = trim($0)
            if (line == "") {
                next
            }
            if (line == "group();") {
                next
            }
            if (line == "group() {" || line ~ /^color\(.*\)[[:space:]]*\{$/ || line == "multmatrix([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]) {") {
                push("wrapper")
                next
            }
            if (line == "}") {
                if (depth > 0 && stack[depth] == "wrapper") {
                    pop()
                    next
                }
                print line
                pop()
                next
            }
            print line
            if (line ~ /\{$/) {
                push("block")
            }
        }
    '
}

test_rel_path() {
    local test_name="$1"
    if [[ "$test_name" == tests/v4/scad/*.scad ]]; then
        echo "$test_name"
    elif [[ "$test_name" == *.scad ]]; then
        echo "tests/v4/scad/$test_name"
    else
        echo "tests/v4/scad/${test_name}.scad"
    fi
}

generate_csg() {
    local source_file="$1"
    local csg_file="$2"
    local log_file="$3"
    local exit_code=0

    timeout "$CSG_TIMEOUT" openscad -o "$csg_file" "$source_file" >"$log_file" 2>&1 || exit_code=$?
    if [[ $exit_code -eq 124 ]]; then
        echo "TIMEOUT after ${CSG_TIMEOUT}s"
        return 1
    fi
    if [[ $exit_code -ne 0 ]]; then
        echo "OpenSCAD exited with $exit_code"
        return 1
    fi
    if grep -qi "ERROR" "$log_file"; then
        echo "OpenSCAD reported ERROR"
        return 1
    fi
    if [[ ! -s "$csg_file" ]]; then
        echo "CSG output is empty"
        return 1
    fi
}

FILES=()
if [[ ${#TESTS[@]} -eq 0 ]]; then
    while IFS= read -r rel; do
        FILES+=("$rel")
    done < <(git -C "$BASELINE_TREE" ls-files 'tests/v4/scad/test_*.scad' | sort)
else
    for test_name in "${TESTS[@]}"; do
        FILES+=("$(test_rel_path "$test_name")")
    done
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No baseline test files found."
    exit 1
fi

BASELINE_SHORT="$(git rev-parse --short "$BASELINE_REF")"
echo "CSG regression baseline: $BASELINE_REF ($BASELINE_SHORT)"
echo "Output: $OUT_DIR"
echo ""

COMPARED=0
UNCHANGED=0
DIFFS=0
SKIPPED=0

for rel in "${FILES[@]}"; do
    name="$(basename "$rel" .scad)"
    baseline_file="$BASELINE_TREE/$rel"
    current_file="$ROOT/$rel"

    if [[ ! -f "$baseline_file" ]]; then
        echo "SKIP $name - no baseline file at $BASELINE_REF"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    if [[ ! -f "$current_file" ]]; then
        echo "FAIL $name - test exists in baseline but not current tree"
        FAIL=$((FAIL + 1))
        continue
    fi

    baseline_csg="$OUT_DIR/${name}.baseline.csg"
    current_csg="$OUT_DIR/${name}.current.csg"
    baseline_norm="$OUT_DIR/${name}.baseline.normalized.csg"
    current_norm="$OUT_DIR/${name}.current.normalized.csg"
    baseline_log="$OUT_DIR/${name}.baseline.log"
    current_log="$OUT_DIR/${name}.current.log"
    diff_file="$DIFF_DIR/${name}.diff"

    if ! reason="$(generate_csg "$baseline_file" "$baseline_csg" "$baseline_log")"; then
        echo "FAIL $name - baseline CSG failed: $reason"
        sed -n '1,8p' "$baseline_log" | sed 's/^/  /'
        FAIL=$((FAIL + 1))
        continue
    fi
    if ! reason="$(generate_csg "$current_file" "$current_csg" "$current_log")"; then
        echo "FAIL $name - current CSG failed: $reason"
        sed -n '1,8p' "$current_log" | sed 's/^/  /'
        FAIL=$((FAIL + 1))
        continue
    fi

    normalize_csg < "$baseline_csg" > "$baseline_norm"
    normalize_csg < "$current_csg" > "$current_norm"
    COMPARED=$((COMPARED + 1))

    if cmp -s "$baseline_norm" "$current_norm"; then
        UNCHANGED=$((UNCHANGED + 1))
    else
        DIFFS=$((DIFFS + 1))
        FAIL=$((FAIL + 1))
        diff -u "$baseline_norm" "$current_norm" > "$diff_file" || true
        echo "DIFF $name - $diff_file"
    fi
done

if [[ ${#TESTS[@]} -eq 0 ]]; then
    while IFS= read -r current_only; do
        [[ -z "$current_only" ]] && continue
        echo "SKIP $(basename "$current_only" .scad) - current-only test has no $BASELINE_REF baseline"
        SKIPPED=$((SKIPPED + 1))
    done < <(comm -13 \
        <(git -C "$BASELINE_TREE" ls-files 'tests/v4/scad/test_*.scad' | sort) \
        <(find "$ROOT/tests/v4/scad" -maxdepth 1 -name 'test_*.scad' -printf 'tests/v4/scad/%f\n' | sort))
fi

echo ""
echo "Results: $UNCHANGED unchanged, $DIFFS changed, $FAIL failures, $SKIPPED skipped (of $COMPARED compared)"

if [[ $FAIL -gt 0 ]]; then
    echo "Generated CSG and diffs kept at: $OUT_DIR"
    exit 1
fi
