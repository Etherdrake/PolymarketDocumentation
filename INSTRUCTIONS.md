# Polymarket Documentation Scraper Instructions

## Overview
This document contains instructions for scraping Polymarket documentation from `docs.polymarket.com` and organizing it into the GitHub repository.

The target URLs are stored in `TARGET.md` - edit that file to add/remove URLs to scrape.

## How It Works

1. **TARGET.md** - Contains the list of URLs to scrape (one per line)
2. **INSTRUCTIONS.md** - This file with scraping instructions
3. **scrape.sh** - The automation script that reads from TARGET.md

## Quick Start

```bash
cd /home/himalaya/clawd/PolymarketDocumentation
./scrape.sh
```

## Directory Structure
Organize the scraped files into the following structure:
```
PolymarketDocumentation/
├── TARGET.md              # Source URLs (edit this file)
├── INSTRUCTIONS.md        # This file
├── scrape.sh              # Automation script
├── quickstart/
│   ├── overview.md
│   ├── fetching-data.md
│   ├── first-order.md
│   └── reference/
│       ├── glossary.md
│       ├── endpoints.md
│       └── introduction/
│           └── rate-limits.md
├── developers/
│   ├── market-makers/
│   │   ├── introduction.md
│   │   ├── setup.md
│   │   ├── trading.md
│   │   ├── liquidity-rewards.md
│   │   ├── maker-rebates-program.md
│   │   ├── data-feeds.md
│   │   └── inventory.md
│   ├── CLOB/
│   │   ├── introduction.md
│   │   ├── status.md
│   │   ├── quickstart.md
│   │   ├── authentication.md
│   │   ├── geoblock.md
│   │   ├── timeseries.md
│   │   ├── clients/
│   │   │   ├── methods-overview.md
│   │   │   ├── methods-public.md
│   │   │   ├── methods-l1.md
│   │   │   ├── methods-l2.md
│   │   │   └── methods-builder.md
│   │   ├── orders/
│   │   │   ├── orders.md
│   │   │   ├── create-order.md
│   │   │   ├── create-order-batch.md
│   │   │   ├── get-order.md
│   │   │   ├── get-active-order.md
│   │   │   ├── check-scoring.md
│   │   │   ├── cancel-orders.md
│   │   │   └── onchain-order-info.md
│   │   ├── trades/
│   │   │   ├── trades-overview.md
│   │   │   └── trades.md
│   │   └── websocket/
│   │       ├── wss-overview.md
│   │       ├── wss-auth.md
│   │       ├── user-channel.md
│   │       └── market-channel.md
│   ├── sports-websocket/
│   │   ├── overview.md
│   │   ├── message-format.md
│   │   └── quickstart.md
│   ├── RTDS/
│   │   ├── RTDS-overview.md
│   │   ├── RTDS-crypto-prices.md
│   │   └── RTDS-comments.md
│   └── gamma-markets-api/
│       ├── overview.md
│       ├── gamma-structure.md
│       └── fetch-markets-guide.md
├── api-reference/
│   ├── orderbook/
│   │   ├── get-order-book-summary.md
│   │   └── get-multiple-order-books-summaries-by-request.md
│   ├── pricing/
│   │   ├── get-market-price.md
│   │   ├── get-multiple-market-prices.md
│   │   ├── get-multiple-market-prices-by-request.md
│   │   ├── get-midpoint-price.md
│   │   └── get-price-history-for-a-traded-token.md
│   └── spreads/
│       └── get-bid-ask-spreads.md
└── quickstart-websocket/
    └── WSS-Quickstart.md
```

## The Scrape Script (scrape.sh)

```bash
#!/bin/bash

# Base URL
BASE_URL="https://docs.polymarket.com"

# Output directory
OUTPUT_DIR="PolymarketDocumentation"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Read URLs from TARGET.md (skip comments and empty lines)
grep -v '^#' "$OUTPUT_DIR/TARGET.md" | grep -v '^$' | while read -r url; do
  # Extract the path portion (remove https://docs.polymarket.com/)
  path="${url#https://docs.polymarket.com/}"
  
  # Remove .md extension for directory structure
  filename=$(basename "$path" .md)
  dir=$(dirname "$path")
  
  # Create directory
  mkdir -p "$OUTPUT_DIR/$dir"
  
  # Determine output file path
  output_file="$OUTPUT_DIR/$path"
  
  # Fetch the page
  echo "Fetching: $url -> $output_file"
  curl -s "$url" -o "$output_file"
  
  # Check if successful
  if [ $? -eq 0 ] && [ -s "$output_file" ]; then
    echo "  ✅ Success: $filename"
  else
    echo "  ❌ Failed: $filename"
  fi
  
  # Rate limit (0.5 seconds between requests)
  sleep 0.5
done

echo "Done! Scraped files to $OUTPUT_DIR/"
```

## Alternative: Using Python Script

```python
#!/usr/bin/env python3
import os
import urllib.request
import time
import re

BASE_URL = "https://docs.polymarket.com"
OUTPUT_DIR = "PolymarketDocumentation"

# Read URLs from TARGET.md
with open("TARGET.md", "r") as f:
    urls = [line.strip() for line in f if line.strip() and not line.startswith("#")]

for url in urls:
    # Extract path and create directories
    path = url.replace("https://docs.polymarket.com/", "")
    filepath = os.path.join(OUTPUT_DIR, path)
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    
    # Fetch the page
    print(f"Fetching: {url}")
    try:
        urllib.request.urlretrieve(url, filepath)
        print(f"  ✅ Saved: {filepath}")
    except Exception as e:
        print(f"  ❌ Error: {e}")
    
    # Rate limit
    time.sleep(0.5)

print("Done!")
```

## Notes
- The `.md` suffix converts HTML pages to markdown format automatically
- Some URLs may require authentication - handle accordingly
- Rate limiting should be respected between requests
- Check for HTTP 200 status codes to verify successful fetches

## Adding New URLs

To add new URLs to scrape, simply edit `TARGET.md` and add the URL on a new line:

```markdown
## New Section
https://docs.polymarket.com/new-section/page.md
```

Then run the scrape script again to fetch the new URLs.
