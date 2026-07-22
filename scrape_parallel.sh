#!/bin/bash
# Fast parallel fetch of Polymarket documentation

OUTPUT_DIR="docs"
mkdir -p "$OUTPUT_DIR"

# Function to fetch a single URL
fetch_url() {
  url="$1"
  path="${url#https://docs.polymarket.com/}"
  dir=$(dirname "$path")
  mkdir -p "$OUTPUT_DIR/$dir"
  output_file="$OUTPUT_DIR/$path"
  
  content=$(curl -s -L -A "Mozilla/5.0 (compatible; Bot/1.0)" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Accept-Language: en-US,en;q=0.5" \
    --max-time 30 \
    "$url")
  
  if [ -n "$content" ]; then
    echo "$content" > "$output_file"
    echo "OK: $path ($(echo "$content" | wc -c) bytes)"
  else
    echo "FAIL: $path"
  fi
}
export -f fetch_url

# Get URLs from TARGET.md and process in parallel
grep -v '^#' TARGET.md | grep -v '^$' | grep 'https://' | while read -r url; do
  echo "$url"
done | xargs -P 8 -I {} bash -c 'fetch_url "$@"' _ {}

echo ""
echo "Scraping complete!"