#!/bin/bash
# Rebuilds docs/ (the GitHub Pages source) from sp500-treemap.declare.
#
# declarec copies every sibling file in this directory as an asset, and
# can't write its output to a location inside its own source tree — so this
# builds to a scratch dir first, then copies just the files GitHub Pages
# actually needs into docs/.
set -euo pipefail

DEMO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DECLARELANG_DIR="$(cd "$DEMO_DIR/../declarelang" && pwd)"
SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

node "$DECLARELANG_DIR/tools/declarec.mjs" \
    "$DECLARELANG_DIR/my-apps/treemap-demo/sp500-treemap.declare" \
    -o "$SCRATCH"

mkdir -p "$DEMO_DIR/docs"
rm -f "$DEMO_DIR"/docs/app.*.js   # each build's hash differs; drop the old one
cp "$SCRATCH"/index.html "$DEMO_DIR/docs/"
cp "$SCRATCH"/app.*.js "$DEMO_DIR/docs/"
cp "$DEMO_DIR/sp500.json" "$DEMO_DIR/docs/"

echo
echo "docs/ ready for GitHub Pages: $DEMO_DIR/docs"
