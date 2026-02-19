#!/usr/bin/env python3
"""
Scrape Polymarket documentation using web_fetch tool.
"""

import subprocess
import json
import os
import time
from pathlib import Path

def fetch_url(url):
    """Use web_fetch to get markdown content from a URL."""
    cmd = [
        "npx", "tsx", "-e",
        f'''
        import tool from "./tool.mjs";
        const result = await tool.read({{path: "/home/himalaya/clawd/PolymarketDocumentation/scrape_single.mjs", limit: 200}});
        console.log(JSON.stringify(result));
        '''
    ]
    
    # Use subprocess to call a Node.js script that uses the web_fetch
    result = subprocess.run(
        ["node", "-e", f'''
        const {{ web_fetch }} = require('./node_modules/openclaw/node_tools.js');
        web_fetch({{url: "{url}"}}).then(r => console.log(JSON.stringify(r, null, 2)));
        '''"],
        capture_output=True,
        text=True,
        cwd="/home/himalaya/clawd"
    )
    return result.stdout

def main():
    # Read TARGET.md
    with open("TARGET.md", "r") as f:
        lines = f.readlines()
    
    # Extract URLs
    urls = []
    for line in lines:
        line = line.strip()
        if line.startswith("https://"):
            urls.append(line)
    
    print(f"Found {len(urls)} URLs to scrape")
    
    # Create docs directory
    Path("docs").mkdir(exist_ok=True)
    
    # Process each URL
    for i, url in enumerate(urls, 1):
        print(f"[{i}/{len(urls)}] Fetching: {url}")
        
        # Extract path
        path = url.replace("https://docs.polymarket.com/", "")
        
        # Create directory structure
        dir_path = Path("docs") / Path(path).parent
        dir_path.mkdir(parents=True, exist_ok=True)
        
        # Output file
        output_file = Path("docs") / path
        
        # Use curl to fetch and web_fetch for markdown extraction
        import subprocess
        result = subprocess.run(
            ["curl", "-s", "-L", "-A", "Mozilla/5.0", url],
            capture_output=True,
            text=True
        )
        
        content = result.stdout
        
        # Save content
        with open(output_file, "w") as f:
            f.write(content)
        
        print(f"  -> {output_file}")
        time.sleep(0.5)
    
    print("Done!")

if __name__ == "__main__":
    main()
