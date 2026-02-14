#!/bin/bash
BASE_URL="https://docs.polymarket.com"
OUTPUT_DIR="docs"

mkdir -p "$OUTPUT_DIR"

# Read URLs from TARGET.md (skip comments and empty lines)
grep -v '^#' TARGET.md | grep -v '^$' | grep 'https://' | while read -r url; do
  # Extract the path portion (remove https://docs.polymarket.com/)
  path="${url#https://docs.polymarket.com/}"
  
  # Create directory
  dir=$(dirname "$path")
  mkdir -p "$OUTPUT_DIR/$dir"
  
  # Determine output file path
  output_file="$OUTPUT_DIR/$path"
  
  # Fetch the page
  echo "Fetching: $url -> $output_file"
  curl -s "$url" -o "$output_file"
  
  # Check if successful
  if [ $? -eq 0 ] && [ -s "$output_file" ]; then
    echo "  ✅ Success"
  else
    echo "  ❌ Failed"
  fi
  
  # Rate limit
  sleep 0.3
done

echo "Done!"
