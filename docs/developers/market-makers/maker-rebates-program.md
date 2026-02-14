> ## Documentation Index
> Fetch the complete documentation index at: https://docs.polymarket.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Maker Rebates Program

> Technical guide for handling taker fees and earning maker rebates on Polymarket

Polymarket has enabled taker fees on **15-minute crypto markets**, **NCAAB (college basketball)**, and **Serie A** markets.
These fees fund a Maker Rebates program that pays daily USDC rebates to liquidity providers.

<Note>
  Starting **Wednesday, February 18th, 2026 at midnight (UTC)**, taker fees and maker rebates will apply to all **new** NCAAB and Serie A markets created after that time. Existing markets are not affected. The first payout will be on February 19th at midnight (UTC).
</Note>

## Fee Handling by Implementation Type

### Option 1: Official CLOB Clients (Recommended)

The official CLOB clients **automatically handle fees** for you

<Card title="TypeScript Client" icon="js" href="https://github.com/Polymarket/clob-client">
  npm install @polymarket/clob-client\@latest
</Card>

<CardGroup cols={2}>
  <Card title="Python Client" icon="python" href="https://github.com/Polymarket/py-clob-client">
    pip install --upgrade py-clob-client
  </Card>

  <Card title="Rust Client" icon="rust" href="https://github.com/Polymarket/rs-clob-client">
    cargo add polymarket-client-sdk
  </Card>
</CardGroup>

**What the client does automatically:**

1. Fetches the fee rate for the market's token ID
2. Includes `feeRateBps` in the order structure
3. Signs the order with the fee rate included

**You don't need to do anything extra**. Your orders will work on fee-enabled markets.

***

### Option 2: REST API / Custom Implementations

If you're calling the REST API directly or building your own order signing, you must manually include the fee rate in your signed order payload.

#### Step 1: Fetch the Fee Rate

Query the fee rate for the token ID before creating your order:

```bash  theme={null}
GET https://clob.polymarket.com/fee-rate?token_id={token_id}
```

**Response:**

```json  theme={null}
{
  "fee_rate_bps": 1000
}
```

* **Fee-enabled markets** return a value like `1000`
* **Fee-free markets** return `0`

#### Step 2: Include in Your Signed Order

Add the `feeRateBps` field to your order object. This value is part of the signed payload, the CLOB validates your signature against it.

```json  theme={null}
{
  "salt": "12345",
  "maker": "0x...",
  "signer": "0x...",
  "taker": "0x...",
  "tokenId": "71321045679252212594626385532706912750332728571942532289631379312455583992563",
  "makerAmount": "50000000",
  "takerAmount": "100000000",
  "expiration": "0",
  "nonce": "0",
  "feeRateBps": "1000",
  "side": "0",
  "signatureType": 2,
  "signature": "0x..."
}
```

#### Step 3: Sign and Submit

1. Include `feeRateBps` in the order object **before signing**
2. Sign the complete order
3. POST to `/order` endpoint

<Note>
  **Important:** Always fetch `fee_rate_bps` dynamically, do not hardcode. The fee rate varies by market type and may change over time. You only need to pass `feeRateBps`
</Note>

See the [Create Order documentation](/developers/CLOB/orders/create-order) for full signing details.

***

## Fee Behavior

Fees are calculated using the following formula:

```text  theme={null}
fee = C × p × feeRate × (p × (1 - p))^exponent
```

Where **C** = number of shares traded and **p** = price of the shares. The fee parameters differ by market type:

| Parameter      | Sports (NCAAB, Serie A) | 15-Min Crypto |
| -------------- | ----------------------- | ------------- |
| Fee Rate       | 0.0175                  | 0.25          |
| Exponent       | 1                       | 2             |
| Maker Rebate % | 25%                     | 20%           |

Taker fees are calculated in USDC and vary based on the share price. However, fees are collected in shares on buy orders and USDC on sell orders.
The effective rate **peaks at 50%** probability and decreases symmetrically toward the extremes.

<img src="https://mintcdn.com/polymarket-292d1b1b/cYugaGfLiC5yQnD1/polymarket-learn/media/fee_image_review.png?fit=max&auto=format&n=cYugaGfLiC5yQnD1&q=85&s=302c97e82876eac5b1bdf962872d6316" alt="Fee Curves" data-og-width="1484" width="1484" data-og-height="882" height="882" data-path="polymarket-learn/media/fee_image_review.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/polymarket-292d1b1b/cYugaGfLiC5yQnD1/polymarket-learn/media/fee_image_review.png?w=280&fit=max&auto=format&n=cYugaGfLiC5yQnD1&q=85&s=5c5ea33f6718c77bc5501eec7d284c7d 280w, https://mintcdn.com/polymarket-292d1b1b/cYugaGfLiC5yQnD1/polymarket-learn/media/fee_image_review.png?w=560&fit=max&auto=format&n=cYugaGfLiC5yQnD1&q=85&s=11f68c179d0f5d8bb20303d3f1847d65 560w, https://mintcdn.com/polymarket-292d1b1b/cYugaGfLiC5yQnD1/polymarket-learn/media/fee_image_review.png?w=840&fit=max&auto=format&n=cYugaGfLiC5yQnD1&q=85&s=2c150cef5a9b1688ee542644bea4a8b5 840w, https://mintcdn.com/polymarket-292d1b1b/cYugaGfLiC5yQnD1/polymarket-learn/media/fee_image_review.png?w=1100&fit=max&auto=format&n=cYugaGfLiC5yQnD1&q=85&s=1a8df2065e4c3e2634c55cbf5eae23a4 1100w, https://mintcdn.com/polymarket-292d1b1b/cYugaGfLiC5yQnD1/polymarket-learn/media/fee_image_review.png?w=1650&fit=max&auto=format&n=cYugaGfLiC5yQnD1&q=85&s=c8c9a753e1c286ebdf03e3e395452cf1 1650w, https://mintcdn.com/polymarket-292d1b1b/cYugaGfLiC5yQnD1/polymarket-learn/media/fee_image_review.png?w=2500&fit=max&auto=format&n=cYugaGfLiC5yQnD1&q=85&s=51b816a9f19219f061e404f35a4d0e13 2500w" />

### Fee Table (100 shares)

<Tabs>
  <Tab title="15-Min Crypto">
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

***

## Maker Rebates

Your rebate for each market:

```text  theme={null}
fee_equivalent = C × p × feeRate × (p × (1 - p))^exponent
rebate = (your_fee_equivalent / total_fee_equivalent) * rebate_pool
```

### How Rebates Work

* **Eligibility:** Your orders must add liquidity (maker orders) and get filled
* **Calculation:** Proportional to your share of executed maker volume in each eligible market. Totals are calculated per market, so you only compete with other makers in the same market
* **Fee collection:** Fees are calculated in USDC but collected in shares on buy orders and USDC on sell orders
* **Payment:** Daily in USDC, paid directly to your wallet

### Rebate Pool

Each market's rebate pool is funded by taker fees collected in that market. The payout percentage is subject to change:

| Market Type             | Period        | Maker Rebate | Distribution Method |
| ----------------------- | ------------- | ------------ | ------------------- |
| 15-Min Crypto           | Jan 19, 2026+ | 20%          | Fee-curve weighted  |
| Sports (NCAAB, Serie A) | Feb 18, 2026+ | 25%          | Fee-curve weighted  |

The rebate percentage is at the sole discretion of Polymarket and may change over time.

***

## Which Markets Have Fees?

The following market types have fees enabled:

* **15-minute crypto markets**
* **NCAAB (college basketball) markets** (starting February 18, 2026 for new markets)
* **Serie A markets** (starting February 18, 2026 for new markets)

Query the fee-rate endpoint to check any specific market:

```bash  theme={null}
GET https://clob.polymarket.com/fee-rate?token_id={token_id}

# Fee-enabled: { "fee_rate_bps": 1000 }
# Fee-free:    { "fee_rate_bps": 0 }
```

***

## Related Documentation

<CardGroup cols={2}>
  <Card title="Maker Rebates Program" icon="coins" href="/polymarket-learn/trading/maker-rebates-program">
    User-facing overview with full fee tables
  </Card>

  <Card title="Create CLOB Order via REST API" icon="code" href="/developers/CLOB/orders/create-order">
    Full order structure and signing documentation
  </Card>
</CardGroup>
