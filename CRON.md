# Polymarket Documentation - Daily Update Instructions for AI Agent

## Mission
Your task is to check for updates to the Polymarket documentation and push any changes to the GitHub repository daily.

## What You Are
You are an AI assistant responsible for keeping the Polymarket documentation synchronized with the official docs.polymarket.com website.

## When to Run
Execute this task once per day. Choose a consistent time (e.g., early morning your time).

## Step-by-Step Instructions

### Step 1: Navigate to the Repository
Go to the PolymarketDocumentation folder:
```
/home/himalaya/clawd/PolymarketDocumentation
```

### Step 2: Check if TARGET.md Has New URLs
Read the TARGET.md file and check if any new URLs have been added compared to what's already been scraped. The file contains a list of documentation URLs that need to be fetched.

### Step 3: Scrape New or Updated Pages
For each URL in TARGET.md that doesn't already have a corresponding file in the docs/ folder, or if you suspect the official docs have been updated:

1. Use the web_fetch tool or curl to fetch each URL
2. Save the content as a .md file in the appropriate docs/ subfolder
3. Match the folder structure to the URL path (e.g., `/quickstart/overview.md` goes in `docs/quickstart/`)

### Step 4: Check for Changes
Run `git status` to see what files have been added or modified.

### Step 5: Commit Changes
If there are new or updated files:
1. Add all changes: `git add -A`
2. Commit with a message that includes today's date, for example: "Update Polymarket documentation - 2026-02-14"
3. Use `git commit` to save the changes locally

### Step 6: Push to GitHub
After committing, push the changes to the remote repository:
```
git push origin main
```

### Step 7: Report
Tell the user what was done:
- How many new files were added
- Which sections were updated
- Confirm the push was successful

## Important Notes

- Only commit and push if there are actual changes
- If TARGET.md hasn't changed and all docs are already scraped, simply report "No updates needed today"
- Keep the folder structure organized - match the URL paths
- The repository is at: https://github.com/Etherdrake/PolymarketDocumentation

## Example Output

When you complete this task, say something like:

"Checked Polymarket documentation. No new URLs in TARGET.md and all 117 files already present. No update needed today."

OR:

"Updated Polymarket documentation: Added 3 new API reference files (get-market-price, get-order-book, list-events). Pushed to GitHub successfully."

## Manual Trigger
If the user asks you to check for updates, run through these steps immediately rather than waiting for your daily schedule.
