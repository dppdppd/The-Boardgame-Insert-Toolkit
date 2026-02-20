#!/bin/bash
#
# BIT Test Runner
# Runs OpenSCAD test files, exports finalized STL, then renders 7 orthographic
# PNG views (top, bottom, front, back, left, right, isometric) from each.
#
# Usage:
#   ./run_tests.sh                  # Run all tests (full 7-view render)
#   ./run_tests.sh test_box_minimal # Run a single test
#   ./run_tests.sh --csg-only       # Only check compilation (fast, no PNG)
#   ./run_tests.sh --views iso,top  # Only render specific views
#   ./run_tests.sh --help           # Show usage
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$SCRIPT_DIR/v4/scad"
RENDER_DIR="$SCRIPT_DIR/v4/renders"
STL_DIR="$SCRIPT_DIR/v4/stl"
IMGSIZE="800,600"
STL_TIMEOUT=900
VIEW_TIMEOUT=30

# Temp file for STL-to-PNG rendering
RENDER_SCAD="/tmp/bit_render_views.scad"
echo 'import(stl_file);' > "$RENDER_SCAD"
cleanup() { rm -f "$RENDER_SCAD"; }
trap cleanup EXIT

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Camera angles: name,rot_x,rot_y,rot_z
# OpenSCAD camera: --camera=tx,ty,tz,rx,ry,rz,dist
ALL_VIEWS="top,0,0,0 bottom,180,0,0 front,90,0,0 back,90,0,180 left,90,0,90 right,90,0,270 iso,55,0,25"

usage() {
    echo "Usage: $0 [OPTIONS] [test_name ...]"
    echo ""
    echo "Options:"
    echo "  --csg-only        Only check compilation (fast, no STL/PNG)"
    echo "  --views LIST      Comma-separated views to render (default: all)"
    echo "                    Available: top,bottom,front,back,left,right,iso"
    echo "  --imgsize WxH     Image size (default: 800,600)"
    echo "  --stl-timeout N   STL export timeout in seconds (default: 300)"
    echo "  --view-timeout N  Per-view PNG timeout in seconds (default: 30)"
    echo "  --help            Show this help"
    echo ""
    echo "Arguments:"
    echo "  test_name         One or more test names (without .scad extension)"
    echo "                    If none specified, runs all tests/test_*.scad"
    echo ""
    echo "Pipeline: .scad → CSG check → STL export → 7x PNG renders (ortho+edges)"
    echo ""
    echo "Examples:"
    echo "  $0                              # Full run, all tests, all views"
    echo "  $0 test_box_minimal             # Single test, all views"
    echo "  $0 --views iso,top test_lid_*   # Only iso+top views for lid tests"
    echo "  $0 --csg-only                   # Fast compile check only"
    exit 0
}

# Preflight: ensure OpenSCAD is installed
if ! command -v openscad &>/dev/null; then
    echo -e "${RED}FATAL${NC}: openscad not found in PATH. Install it first."
    exit 1
fi

CSG_ONLY=false
REQUESTED_VIEWS=""
TESTS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --csg-only)       CSG_ONLY=true; shift ;;
        --views)          REQUESTED_VIEWS="$2"; shift 2 ;;
        --imgsize)        IMGSIZE="$2"; shift 2 ;;
        --stl-timeout)    STL_TIMEOUT="$2"; shift 2 ;;
        --view-timeout)   VIEW_TIMEOUT="$2"; shift 2 ;;
        --help)           usage ;;
        *)                TESTS+=("$1"); shift ;;
    esac
done

# Build view list
VIEWS=()
if [[ -n "$REQUESTED_VIEWS" ]]; then
    IFS=',' read -ra REQ <<< "$REQUESTED_VIEWS"
    for r in "${REQ[@]}"; do
        for v in $ALL_VIEWS; do
            vname="${v%%,*}"
            if [[ "$vname" == "$r" ]]; then
                VIEWS+=("$v")
            fi
        done
    done
else
    for v in $ALL_VIEWS; do
        VIEWS+=("$v")
    done
fi

mkdir -p "$RENDER_DIR" "$STL_DIR"

# Build file list
FILES=()
if [[ ${#TESTS[@]} -eq 0 ]]; then
    for f in "$TEST_DIR"/test_*.scad; do
        [[ -f "$f" ]] && FILES+=("$f")
    done
else
    for t in "${TESTS[@]}"; do
        f="$TEST_DIR/${t}.scad"
        if [[ -f "$f" ]]; then
            FILES+=("$f")
        else
            echo -e "${RED}SKIP${NC} $t — file not found: $f"
        fi
    done
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No test files found."
    exit 1
fi

TOTAL=${#FILES[@]}
PASS=0
FAIL=0
WARN=0
TOTAL_START=$(date +%s)

echo -e "${CYAN}Running $TOTAL test(s), ${#VIEWS[@]} view(s) each...${NC}"
echo ""

for f in "${FILES[@]}"; do
    name="$(basename "$f" .scad)"
    TEST_START=$(date +%s)

    # Phase 1: CSG compilation check (fast, ~0.3s)
    csg_out=$(mktemp /tmp/bit_csg_XXXXXX.csg)
    csg_err=$(timeout 30 openscad -o "$csg_out" "$f" 2>&1) || true
    csg_exit=$?

    has_error=false
    has_warning=false

    if [[ $csg_exit -eq 124 ]]; then
        has_error=true
        csg_err="TIMEOUT on CSG export"
    elif echo "$csg_err" | grep -qi "ERROR"; then
        has_error=true
    fi
    if echo "$csg_err" | grep -qi "WARNING"; then
        has_warning=true
    fi

    # Check for empty geometry
    if [[ -f "$csg_out" ]]; then
        csg_lines=$(wc -l < "$csg_out")
        if [[ $csg_lines -lt 5 ]]; then
            has_warning=true
            csg_err="${csg_err}
WARNING: CSG output nearly empty ($csg_lines lines)"
        fi
    fi
    rm -f "$csg_out"

    if $has_error; then
        echo -e "${RED}FAIL${NC} $name — compile error"
        echo "$csg_err" | head -5 | sed 's/^/  /'
        FAIL=$((FAIL + 1))
        continue
    fi

    # Phase 2: STL export + multi-view PNG render
    if ! $CSG_ONLY; then
        stl_out="$STL_DIR/${name}.stl"
        stl_exit=0
        stl_err=$(timeout "$STL_TIMEOUT" openscad -o "$stl_out" "$f" 2>&1) || stl_exit=$?

        if [[ $stl_exit -eq 124 ]]; then
            echo -e "${RED}FAIL${NC} $name — STL export timeout (${STL_TIMEOUT}s)"
            rm -f "$stl_out"
            FAIL=$((FAIL + 1))
            continue
        fi

        if [[ ! -s "$stl_out" ]]; then
            echo -e "${RED}FAIL${NC} $name — STL export empty (exit=$stl_exit)"
            echo "$stl_err" | tail -5 | sed 's/^/  /'
            rm -f "$stl_out"
            FAIL=$((FAIL + 1))
            continue
        fi

        # Phase 3: Render views from STL (fast, ~1s each)
        view_fail=false
        for v in "${VIEWS[@]}"; do
            IFS=',' read -r vname rx ry rz <<< "$v"
            png_out="$RENDER_DIR/${name}_${vname}.png"

            timeout "$VIEW_TIMEOUT" xvfb-run -a openscad --render -o "$png_out" \
                --imgsize="$IMGSIZE" --autocenter --viewall \
                --projection=ortho --view=edges \
                --camera=0,0,0,$rx,$ry,$rz,0 \
                -D "stl_file=\"$stl_out\"" \
                "$RENDER_SCAD" >/dev/null 2>&1

            if [[ ! -s "$png_out" ]]; then
                echo -e "${RED}FAIL${NC} $name — ${vname} view failed"
                view_fail=true
                break
            fi
        done

        if $view_fail; then
            FAIL=$((FAIL + 1))
            continue
        fi
    fi

    TEST_END=$(date +%s)
    elapsed=$((TEST_END - TEST_START))

    if $has_warning; then
        echo -e "${YELLOW}WARN${NC} $name (${elapsed}s)"
        echo "$csg_err" | grep -i "WARNING" | head -3 | sed 's/^/  /'
        WARN=$((WARN + 1))
    else
        echo -e "${GREEN}PASS${NC} $name (${elapsed}s)"
    fi
    PASS=$((PASS + 1))
done

TOTAL_END=$(date +%s)
TOTAL_ELAPSED=$((TOTAL_END - TOTAL_START))

echo ""
echo -e "${CYAN}Results: $PASS passed, $FAIL failed, $WARN warnings (of $TOTAL total) in ${TOTAL_ELAPSED}s${NC}"
if ! $CSG_ONLY; then
    echo -e "${CYAN}Renders: $RENDER_DIR/${NC}"
fi

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
