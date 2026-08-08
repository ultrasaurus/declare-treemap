#!/bin/bash
# Rebuilds docs/ (the GitHub Pages source) from every demo variant listed
# below, each into its own subfolder, plus a landing index.html linking to
# all of them.
#
# declarec copies every sibling file in this directory as an asset, and
# can't write its output to a location inside its own source tree — so this
# builds each variant to a scratch dir first, then copies just the files
# GitHub Pages actually needs into docs/<name>/.
set -euo pipefail

DEMO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DECLARELANG_DIR="$(cd "$DEMO_DIR/../declarelang" && pwd)"
SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

# name -> source file -> nav label
VARIANTS_NAME=(latest toggle)
VARIANTS_FILE=(sp500-treemap.declare sp500-treemap-toggle.declare)
VARIANTS_LABEL=("Latest (order snaps, size glides)" "Toggle (before sortWeight fix — rows reshuffle)")

for i in "${!VARIANTS_NAME[@]}"; do
    name="${VARIANTS_NAME[$i]}"
    src="${VARIANTS_FILE[$i]}"
    out="$SCRATCH/$name"
    node "$DECLARELANG_DIR/tools/declarec.mjs" \
        "$DECLARELANG_DIR/my-apps/treemap-demo/$src" \
        -o "$out"

    mkdir -p "$DEMO_DIR/docs/$name"
    rm -f "$DEMO_DIR"/docs/"$name"/app.*.js
    cp "$out"/index.html "$DEMO_DIR/docs/$name/"
    cp "$out"/app.*.js "$DEMO_DIR/docs/$name/"
    cp "$DEMO_DIR/sp500.json" "$DEMO_DIR/docs/$name/"
done

cat > "$DEMO_DIR/docs/index.html" << HTML
<!doctype html>
<meta charset="utf-8">
<title>S&P 500 Treemap — demo variants</title>
<style>
  body { font: 16px/1.5 -apple-system, sans-serif; max-width: 32rem; margin: 4rem auto; padding: 0 1rem; }
  h1 { font-size: 1.25rem; }
  ul { padding-left: 1.2rem; }
  a { color: #2a5adf; }
</style>
<h1>S&P 500 Treemap — demo variants</h1>
<ul>
HTML
for i in "${!VARIANTS_NAME[@]}"; do
    name="${VARIANTS_NAME[$i]}"
    label="${VARIANTS_LABEL[$i]}"
    echo "  <li><a href=\"./$name/\">$label</a></li>" >> "$DEMO_DIR/docs/index.html"
done
echo "</ul>" >> "$DEMO_DIR/docs/index.html"

echo
echo "docs/ ready for GitHub Pages: $DEMO_DIR/docs"
