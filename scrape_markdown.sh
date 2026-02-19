#!/bin/bash
# Fetch Polymarket documentation as markdown

OUTPUT_DIR="docs"
mkdir -p "$OUTPUT_DIR"

# Read URLs from TARGET.md
grep -v '^#' TARGET.md | grep -v '^$' | grep 'https://' | while read -r url; do
  # Extract the path portion
  path="${url#https://docs.polymarket.com/}"
  
  # Create directory
  dir=$(dirname "$path")
  mkdir -p "$OUTPUT_DIR/$dir"
  
  # Output file
  output_file="$OUTPUT_DIR/$path"
  
  # Fetch the page with proper headers
  echo "Fetching: $url"
  content=$(curl -s -L -A "Mozilla/5.0 (compatible; Bot/1.0)" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Accept-Language: en-US,en;q=0.5" \
    "$url")
  
  if [ -n "$content" ]; then
    echo "$content" > "$output_file"
    echo "  -> Saved to $output_file ($(echo "$content" | wc -c) bytes)"
  else
    echo "  -> Failed to fetch"
  fi
  
  sleep 0.3
done

echo ""
echo "Scraping complete!"
