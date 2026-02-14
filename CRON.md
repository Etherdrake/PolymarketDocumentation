# Polymarket Documentation - Daily Sync Cron Job

## Overview
This cron job checks for updates to the Polymarket documentation and pushes any changes to the GitHub repository daily.

## Schedule
- **Time:** Every day at 06:00 UTC (adjust to your preference)
- **Frequency:** Daily

## Instructions

### 1. Check for Updates
```bash
# Navigate to the repository
cd /home/himalaya/clawd/PolymarketDocumentation

# Fetch latest from remote
git fetch origin

# Check for changes
git status

# If there are changes in TARGET.md, re-run the scrape
if [ -n "$(git diff origin/main -- TARGET.md)" ]; then
    echo "TARGET.md changed - re-scraping..."
    ./scrape.sh
fi
```

### 2. Add and Commit Changes
```bash
# Add all new/modified files
git add -A

# Check if there are changes to commit
if [ -n "$(git status --porcelain)" ]; then
    git commit -m "Update Polymarket documentation - $(date -u +%Y-%m-%d)"
else
    echo "No changes to commit"
    exit 0
fi
```

### 3. Push Changes
```bash
git push origin main
```

## Complete Cron Script

Save this as `daily-sync.sh` and run via cron:

```bash
#!/bin/bash
# Polymarket Documentation Daily Sync
# Runs daily to check for doc updates and push changes

set -e

REPO_DIR="/home/himalaya/clawd/PolymarketDocumentation"
cd "$REPO_DIR"

echo "=== $(date -u) Starting daily sync ==="

# Fetch latest
git fetch origin

# Check if TARGET.md changed
if ! git diff --quiet origin/main -- TARGET.md; then
    echo "TARGET.md changed - re-scraping..."
    ./scrape.sh
fi

# Stage all changes
git add -A

# Check if there are changes to commit
if [ -n "$(git status --porcelain)" ]; then
    echo "Committing changes..."
    git commit -m "Update Polymarket documentation - $(date -u +%Y-%m-%d)"
    
    echo "Pushing to GitHub..."
    git push origin main
    
    echo "=== Sync complete ==="
else
    echo "No changes to commit"
fi
```

## Cron Setup

Add to crontab:
```bash
# Daily at 06:00 UTC
0 6 * * * /home/himalaya/clawd/PolymarketDocumentation/daily-sync.sh >> /home/himalaya/clawd/PolymarketDocumentation/sync.log 2>&1
```

Or use OpenClaw cron:
```bash
openclaw cron add --schedule "0 6 * * *" --payload "systemEvent" --text "Run Polymarket docs daily sync" --sessionTarget "main"
```

## Log File
Logs are written to: `sync.log`

## Manual Run
To run manually:
```bash
cd /home/himalaya/clawd/PolymarketDocumentation
./daily-sync.sh
```

## Notes
- The scrape script fetches all URLs listed in TARGET.md
- Only commits if there are actual changes
- Skips commit if docs haven't changed
- Safe to run multiple times per day if needed
