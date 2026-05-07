#!/usr/bin/env bash
# Validate an arbitrary BIT user design file.
#
# This is for generated or hand-written user .scad files. Library regression
# tests still use tests/run_tests.sh.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTDIR="$ROOT_DIR/tests/v4/renders/generated"
IMGSIZE="1600,1200"
CSG_TIMEOUT=60
STL_TIMEOUT=900
VIEW_TIMEOUT=30
VIEWS="iso,top"
RENDER=false
NAME=""
INPUT_FILE=""

usage() {
    cat <<'EOF'
Usage: scripts/validate-design.sh [OPTIONS] path/to/design.scad

Fast compile check for arbitrary BIT user designs. Use --render to also export
STL and render PNG views.

Options:
  --render          Export STL and render views after compile succeeds
  --views LIST      Comma-separated views to render (default: iso,top)
                   Available: top,bottom,front,back,left,right,iso
  --outdir DIR      Output directory (default: tests/v4/renders/generated)
  --name NAME       Base name for output files (default: input basename)
  --imgsize WxH     PNG image size (default: 1600,1200)
  --csg-timeout N   CSG compile timeout in seconds (default: 60)
  --stl-timeout N   STL export timeout in seconds (default: 900)
  --view-timeout N  Per-view PNG timeout in seconds (default: 30)
  --help            Show this help

Examples:
  scripts/validate-design.sh release/my_designs/starter.scad
  scripts/validate-design.sh --render --views iso,top docs/llm/examples/two-decks-button-sliding.scad
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --render)
            RENDER=true
            shift
            ;;
        --views)
            VIEWS="$2"
            shift 2
            ;;
        --outdir)
            OUTDIR="$2"
            shift 2
            ;;
        --name)
            NAME="$2"
            shift 2
            ;;
        --imgsize)
            IMGSIZE="$2"
            shift 2
            ;;
        --csg-timeout)
            CSG_TIMEOUT="$2"
            shift 2
            ;;
        --stl-timeout)
            STL_TIMEOUT="$2"
            shift 2
            ;;
        --view-timeout)
            VIEW_TIMEOUT="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
        *)
            if [[ -n "$INPUT_FILE" ]]; then
                echo "Only one input file is supported" >&2
                exit 2
            fi
            INPUT_FILE="$1"
            shift
            ;;
    esac
done

if [[ -z "$INPUT_FILE" ]]; then
    usage >&2
    exit 2
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Missing input file: $INPUT_FILE" >&2
    exit 1
fi

if ! command -v openscad >/dev/null 2>&1; then
    echo "FATAL: openscad not found in PATH" >&2
    exit 1
fi

if [[ "$RENDER" == true ]] && ! command -v xvfb-run >/dev/null 2>&1; then
    echo "FATAL: xvfb-run not found in PATH; omit --render for compile-only validation" >&2
    exit 1
fi

mkdir -p "$OUTDIR"

if [[ -z "$NAME" ]]; then
    NAME="$(basename "$INPUT_FILE" .scad)"
fi

CSG_FILE="$OUTDIR/${NAME}.csg"
LOG_FILE="$OUTDIR/${NAME}.log"
STL_FILE="$OUTDIR/${NAME}.stl"
RENDER_SCAD="$(mktemp /tmp/bit_validate_render_XXXXXX.scad)"

cleanup() {
    rm -f "$RENDER_SCAD"
}
trap cleanup EXIT

echo "=== BIT Design Validation: $NAME ==="
echo "Input: $INPUT_FILE"
echo "Output: $OUTDIR"

echo -n "Compile CSG... "
csg_exit=0
timeout "$CSG_TIMEOUT" openscad -o "$CSG_FILE" "$INPUT_FILE" >"$LOG_FILE" 2>&1 || csg_exit=$?

if [[ $csg_exit -eq 124 ]]; then
    echo "TIMEOUT (${CSG_TIMEOUT}s)"
    echo "Log: $LOG_FILE"
    exit 1
elif [[ $csg_exit -ne 0 ]]; then
    echo "FAILED (exit=$csg_exit)"
    grep -i "ERROR" "$LOG_FILE" | head -10 || tail -10 "$LOG_FILE"
    echo "Log: $LOG_FILE"
    exit 1
fi

if grep -qi "ERROR" "$LOG_FILE"; then
    echo "FAILED"
    grep -i "ERROR" "$LOG_FILE" | head -10
    echo "Log: $LOG_FILE"
    exit 1
fi

if [[ ! -s "$CSG_FILE" ]]; then
    echo "FAILED (empty CSG)"
    echo "Log: $LOG_FILE"
    exit 1
fi

echo "OK"

warning_count=$(grep -Eci "WARNING|BGSD_(WARNING|ERROR|INFO):|BIT:" "$LOG_FILE" || true)
if [[ "$warning_count" -gt 0 ]]; then
    echo "Warnings/messages ($warning_count):"
    grep -Ei "WARNING|BGSD_(WARNING|ERROR|INFO):|BIT:" "$LOG_FILE" | head -20 | sed 's/^/  /'
fi

if [[ "$RENDER" != true ]]; then
    echo "CSG: $CSG_FILE"
    echo "Log: $LOG_FILE"
    exit 0
fi

echo -n "Export STL... "
stl_exit=0
timeout "$STL_TIMEOUT" openscad -o "$STL_FILE" "$INPUT_FILE" >>"$LOG_FILE" 2>&1 || stl_exit=$?

if [[ $stl_exit -eq 124 ]]; then
    echo "TIMEOUT (${STL_TIMEOUT}s)"
    echo "Log: $LOG_FILE"
    exit 1
elif [[ $stl_exit -ne 0 ]]; then
    echo "FAILED (exit=$stl_exit)"
    grep -i "ERROR" "$LOG_FILE" | tail -10 || tail -10 "$LOG_FILE"
    echo "Log: $LOG_FILE"
    exit 1
fi

if [[ ! -s "$STL_FILE" ]]; then
    echo "FAILED (empty STL)"
    echo "Log: $LOG_FILE"
    exit 1
fi

echo "OK"

printf 'import(stl_file);\n' > "$RENDER_SCAD"

declare -A CAMERAS=(
    [top]="0,0,0"
    [bottom]="180,0,0"
    [front]="90,0,0"
    [back]="90,0,180"
    [left]="90,0,90"
    [right]="90,0,270"
    [iso]="55,0,25"
)

IFS=',' read -ra VIEW_LIST <<< "$VIEWS"
for view_name in "${VIEW_LIST[@]}"; do
    if [[ -z "${CAMERAS[$view_name]+x}" ]]; then
        echo "Unknown view: $view_name" >&2
        exit 2
    fi

    IFS=',' read -r rx ry rz <<< "${CAMERAS[$view_name]}"
    png_file="$OUTDIR/${NAME}_${view_name}.png"
    echo -n "Render $view_name... "

    render_exit=0
    timeout "$VIEW_TIMEOUT" xvfb-run -a openscad --render -o "$png_file" \
        --imgsize="$IMGSIZE" --autocenter --viewall \
        --projection=ortho --view=edges \
        --camera=0,0,0,$rx,$ry,$rz,0 \
        -D "stl_file=\"$STL_FILE\"" \
        "$RENDER_SCAD" >>"$LOG_FILE" 2>&1 || render_exit=$?

    if [[ $render_exit -eq 124 ]]; then
        echo "TIMEOUT (${VIEW_TIMEOUT}s)"
        echo "Log: $LOG_FILE"
        exit 1
    elif [[ $render_exit -ne 0 || ! -s "$png_file" ]]; then
        echo "FAILED"
        echo "Log: $LOG_FILE"
        exit 1
    fi

    echo "$png_file"
done

final_warning_count=$(grep -Eci "WARNING|BGSD_(WARNING|ERROR|INFO):|BIT:" "$LOG_FILE" || true)
if [[ "$final_warning_count" -gt "$warning_count" ]]; then
    echo "Additional warnings/messages after STL export or render ($((final_warning_count - warning_count))):"
    grep -Ei "WARNING|BGSD_(WARNING|ERROR|INFO):|BIT:" "$LOG_FILE" | tail -20 | sed 's/^/  /'
fi

echo "STL: $STL_FILE"
echo "Log: $LOG_FILE"
