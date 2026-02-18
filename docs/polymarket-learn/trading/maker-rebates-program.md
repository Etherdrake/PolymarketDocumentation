> ## Documentation Index
> Fetch the complete documentation index at: https://docs.polymarket.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Maker Rebates Program

Polymarket has enabled taker fees on **15-minute crypto markets**, **5-minute crypto markets**, **NCAAB (college basketball)**, and **Serie A** markets. These fees fund a **Maker Rebates** program that pays daily USDC rebates to liquidity providers.

<Note>
  Starting **Wednesday, February 18th, 2026 at midnight (UTC)**, taker fees and maker rebates will apply to all **new** NCAAB and Serie A markets created after that time. Existing markets are not affected. The first payout will be on February 19th at midnight (UTC).
</Note>

## Why Expand Maker Rebates?

Sports markets benefit from the same dynamics as our 15-minute crypto and 5-minute crypto markets. When liquidity is deeper:

* Spreads tend to be tighter
* Price impact is lower
* Fills are more reliable
* Markets are more resilient during volatility

Maker Rebates incentivize consistent, competitive quoting so everyone gets a better trading experience.

### Program Funding

Maker Rebates are funded by taker fees collected in eligible markets. A percentage of these fees are redistributed to makers who keep the markets liquid. The rebate percentage differs by market type.

| Market Type             | Period        | Maker Rebate | Distribution Method |
| ----------------------- | ------------- | ------------ | ------------------- |
| 15-Min Crypto           | Jan 19, 2026+ | 20%          | Fee-curve weighted  |
| 5-Min Crypto            | Feb 12, 2026+ | 20%          | Fee-curve weighted  |
| Sports (NCAAB, Serie A) | Feb 18, 2026+ | 25%          | Fee-curve weighted  |

<Note>
  Polymarket collects taker fees in eligible markets (15-minute crypto, 5-minute crypto, NCAAB, and Serie A). The rebate percentage is at the sole discretion of Polymarket and may change over time.
</Note>

## Taker Fee Structure

Taker fees are calculated in USDC and vary based on the share price. However, fees are collected in shares on buy orders and USDC on sell orders.
Fees are highest at 50% probability and lowest at the extremes (near 0% or 100%).

<img src="https://mintcdn.com/polymarket-292d1b1b/12mKTb6PQ_jJnYbI/polymarket-learn/media/fee_image_review.png?fit=max&auto=format&n=12mKTb6PQ_jJnYbI&q=85&s=9e5b1d1a262fb6c787af5b6a0fa4d6c2" alt="Fee Curves" data-og-width="1484" width="1484" data-og-height="882" height="882" data-path="polymarket-learn/media/fee_image_review.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/polymarket-292d1b1b/12mKTb6PQ_jJnYbI/polymarket-learn/media/fee_image_review.png?w=280&fit=max&auto=format&n=12mKTb6PQ_jJnYbI&q=85&s=111b6dc97e2b301501c02e2df5e3df35 280w, https://mintcdn.com/polymarket-292d1b1b/12mKTb6PQ_jJnYbI/polymarket-learn/media/fee_image_review.png?w=560&fit=max&auto=format&n=12mKTb6PQ_jJnYbI&q=85&s=063f99ef8ec728e399a7cd0b27e704a0 560w, https://mintcdn.com/polymarket-292d1b1b/12mKTb6PQ_jJnYbI/polymarket-learn/media/fee_image_review.png?w=840&fit=max&auto=format&n=12mKTb6PQ_jJnYbI&q=85&s=c7d74e4ca10bd953f1f08a9851017f3c 840w, https://mintcdn.com/polymarket-292d1b1b/12mKTb6PQ_jJnYbI/polymarket-learn/media/fee_image_review.png?w=1100&fit=max&auto=format&n=12mKTb6PQ_jJnYbI&q=85&s=bc3dbf551ae32d6c4e7d85558831fb1f 1100w, https://mintcdn.com/polymarket-292d1b1b/12mKTb6PQ_jJnYbI/polymarket-learn/media/fee_image_review.png?w=1650&fit=max&auto=format&n=12mKTb6PQ_jJnYbI&q=85&s=d082a6e2029bc3f4797d758d689e2c37 1650w, https://mintcdn.com/polymarket-292d1b1b/12mKTb6PQ_jJnYbI/polymarket-learn/media/fee_image_review.png?w=2500&fit=max&auto=format&n=12mKTb6PQ_jJnYbI&q=85&s=417d0c9a66a64d31588d15c908cebf39 2500w" />

### Fee Table (100 shares)

<Tabs>
  <Tab title="5-Min & 15-Min Crypto">
    | Price  | Trade Value | Fee (USDC) | Effective Rate |
    | ------ | ----------- | ---------- | -------------- |
    | \$0.01 | \$1         | \$0.00     | 0.00%          |
    | \$0.05 | \$5         | \$0.003    | 0.06%          |
    | \$0.10 | \$10        | \$0.02     | 0.20%          |
    | \$0.15 | \$15        | \$0.06     | 0.41%          |
    | \$0.20 | \$20        | \$0.13     | 0.64%          |
    | \$0.25 | \$25        | \$0.22     | 0.88%          |
    | \$0.30 | \$30        | \$0.33     | 1.10%          |
    | \$0.35 | \$35        | \$0.45     | 1.29%          |
    | \$0.40 | \$40        | \$0.58     | 1.44%          |
    | \$0.45 | \$45        | \$0.69     | 1.53%          |
    | \$0.50 | \$50        | \$0.78     | **1.56%**      |
    | \$0.55 | \$55        | \$0.84     | 1.53%          |
    | \$0.60 | \$60        | \$0.86     | 1.44%          |
    | \$0.65 | \$65        | \$0.84     | 1.29%          |
    | \$0.70 | \$70        | \$0.77     | 1.10%          |
    | \$0.75 | \$75        | \$0.66     | 0.88%          |
    | \$0.80 | \$80        | \$0.51     | 0.64%          |
    | \$0.85 | \$85        | \$0.35     | 0.41%          |
    | \$0.90 | \$90        | \$0.18     | 0.20%          |
    | \$0.95 | \$95        | \$0.05     | 0.06%          |
    | \$0.99 | \$99        | \$0.00     | 0.00%          |

    The maximum effective fee rate is **1.56%** at 50% probability. Fees decrease symmetrically toward both extremes.
  </Tab>

  <Tab title="Sports (NCAAB, Serie A)">
    | Price  | Trade Value | Fee (USDC) | Effective Rate |
    | ------ | ----------- | ---------- | -------------- |
    | \$0.01 | \$1         | \$0.00     | 0.02%          |
    | \$0.05 | \$5         | \$0.00     | 0.08%          |
    | \$0.10 | \$10        | \$0.02     | 0.16%          |
    | \$0.15 | \$15        | \$0.03     | 0.22%          |
    | \$0.20 | \$20        | \$0.06     | 0.28%          |
    | \$0.25 | \$25        | \$0.08     | 0.33%          |
    | \$0.30 | \$30        | \$0.11     | 0.37%          |
    | \$0.35 | \$35        | \$0.14     | 0.40%          |
    | \$0.40 | \$40        | \$0.17     | 0.42%          |
    | \$0.45 | \$45        | \$0.19     | 0.43%          |
    | \$0.50 | \$50        | \$0.22     | **0.44%**      |
    | \$0.55 | \$55        | \$0.24     | 0.43%          |
    | \$0.60 | \$60        | \$0.25     | 0.42%          |
    | \$0.65 | \$65        | \$0.26     | 0.40%          |
    | \$0.70 | \$70        | \$0.26     | 0.37%          |
    | \$0.75 | \$75        | \$0.25     | 0.33%          |
    | \$0.80 | \$80        | \$0.22     | 0.28%          |
    | \$0.85 | \$85        | \$0.19     | 0.22%          |
    | \$0.90 | \$90        | \$0.14     | 0.16%          |
    | \$0.95 | \$95        | \$0.08     | 0.08%          |
    | \$0.99 | \$99        | \$0.02     | 0.02%          |

    The maximum effective fee rate is **0.44%** at 50% probability. Fees decrease symmetrically toward both extremes.
  </Tab>
</Tabs>

### Fee Precision

Fees are rounded to 4 decimal places. The smallest fee charged is 0.0001 USDC. Anything smaller rounds to zero, so very small trades near the extremes may incur no fee at all.

## FAQ

<AccordionGroup>
  <Accordion title="How are rebates calculated?">
    Rebates are proportional to your share of executed maker liquidity in each eligible market. Totals are calculated per market, so you only compete with other makers in the same market.
  </Accordion>

  <Accordion title="Which markets have fees enabled?">
    15-minute crypto markets, 5-minute crypto markets, and starting February 18, 2026, NCAAB and Serie A markets.
  </Accordion>

  <Accordion title="Is Polymarket charging fees on all markets?">
    No. Fees apply only to 15-minute crypto, 5-minute crypto, NCAAB, and Serie A markets. All other markets remain fee-free.
  </Accordion>
</AccordionGroup>

## For API Users

If you trade programmatically, you'll need to update your client to handle fees correctly.

<Card title="Developer Guide: Maker Rebates" icon="code" href="/developers/market-makers/maker-rebates-program">
  Technical documentation for handling fees in your trading code
</Card>
