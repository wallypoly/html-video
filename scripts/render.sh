#!/usr/bin/env bash
# html-video/render.sh — single-command video rendering for the UNIQorn pipeline.
#
# Inputs come from 小角 (copy) and 顾哥 (template choice + aspect).
# This script does not write copy or pick templates; it only renders.
#
# Usage:
#   render.sh --vars <path> --template <id> --output <path> [--aspect 16:9|9:16|1:1] [--name <label>]
#
# Defaults:
#   --aspect 16:9   (html-video templates are 16:9-native; 9:16 overflows.)
#   --name   inferred from vars filename stem.
#
# Exit codes:
#   0   success
#   2   bad usage
#   3   missing input file
#   4   render failed (CLI non-zero exit)
#   5   output file missing after render

set -euo pipefail

# ---- locate repo + managed node + pnpm ------------------------------------
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANAGED_NODE="/Users/wallypoly/.workbuddy-ai/binaries/node/versions/22.22.2-2/bin/node"
PNPM_BIN="/Users/wallypoly/.workbuddy-ai/binaries/node/workspace/node_modules/pnpm/bin/pnpm.cjs"
CLI_BIN="$REPO_ROOT/packages/cli/dist/bin.js"

if [ ! -x "$CLI_BIN" ]; then
  echo "error: $CLI_BIN not built. Run: pnpm -r build" >&2
  exit 5
fi

# ---- args ----------------------------------------------------------------
VARS_FILE=""
TEMPLATE_ID=""
OUTPUT_PATH=""
ASPECT="16:9"
NAME=""

while [ $# -gt 0 ]; do
  case "$1" in
    --vars)     VARS_FILE="$2"; shift 2 ;;
    --template) TEMPLATE_ID="$2"; shift 2 ;;
    --output)   OUTPUT_PATH="$2"; shift 2 ;;
    --aspect)   ASPECT="$2"; shift 2 ;;
    --name)     NAME="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,18p' "$0"; exit 0 ;;
    *)
      echo "error: unknown argument '$1'" >&2; exit 2 ;;
  esac
done

# ---- validate ------------------------------------------------------------
[ -n "$VARS_FILE" ]   || { echo "error: --vars <path> required" >&2; exit 2; }
[ -n "$TEMPLATE_ID" ] || { echo "error: --template <id> required" >&2; exit 2; }
[ -n "$OUTPUT_PATH" ] || { echo "error: --output <path> required" >&2; exit 2; }

if [ ! -f "$VARS_FILE" ]; then
  echo "error: vars file not found: $VARS_FILE" >&2; exit 3
fi

if [ -z "$NAME" ]; then
  NAME="$(basename "$VARS_FILE" .json)"
fi

case "$ASPECT" in
  16:9|9:16|1:1) ;;
  *)
    echo "error: --aspect must be 16:9, 9:16, or 1:1 (got '$ASPECT')" >&2; exit 2 ;;
esac

mkdir -p "$(dirname "$OUTPUT_PATH")"

# ---- run pipeline --------------------------------------------------------
cd "$REPO_ROOT"
JSON_OUT="$("$MANAGED_NODE" "$CLI_BIN" project-create --name "$NAME" --intent "render.sh" --aspect "$ASPECT")"
PROJECT_ID="$(echo "$JSON_OUT" | "$MANAGED_NODE" -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log(JSON.parse(s).project_id))')"

"$MANAGED_NODE" "$CLI_BIN" project-set-template "$PROJECT_ID" --template "$TEMPLATE_ID" > /dev/null
"$MANAGED_NODE" "$CLI_BIN" project-set-vars    "$PROJECT_ID" --vars-file "$VARS_FILE" > /dev/null

if ! "$MANAGED_NODE" "$CLI_BIN" project-render "$PROJECT_ID" --output "$OUTPUT_PATH" > /dev/null 2>&1; then
  echo "error: render failed for project $PROJECT_ID" >&2
  exit 4
fi

[ -f "$OUTPUT_PATH" ] || { echo "error: output missing after render" >&2; exit 5; }

echo "rendered: $OUTPUT_PATH"
echo "project:  $PROJECT_ID"
echo "template: $TEMPLATE_ID"
echo "aspect:   $ASPECT"
