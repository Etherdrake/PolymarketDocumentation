> ## Documentation Index
> Fetch the complete documentation index at: https://docs.polymarket.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Polymarket Changelog

> Welcome to the Polymarket Changelog. Here you will find any important changes to Polymarket, including but not limited to CLOB, API, UI and Mobile Applications.

<Update label="May 12, 2026" description="Increased API Rate Limits">
  Increased burst and sustained rate limits for several CLOB trading endpoints.
  * CLOB POST /order - 5000 every 10s (500/s) - (BURST)
  * CLOB POST /order - 48000 every 10 minutes (80/s)
  * CLOB DELETE /order - 5000 every 10s (500/s) - (BURST)
  * CLOB DELETE /order - 48000 every 10 minutes (80/s)
  * CLOB POST /orders - 1500 every 10s (150/s) - (BURST)
  * CLOB POST /orders - 21000 every 10 minutes (35/s)
  * CLOB DELETE /cancel-market-orders - 1500 every 10s (150/s) - (BURST)
  * CLOB DELETE /cancel-market-orders - 21000 every 10 minutes (35/s)
  See [Rate Limits](/api-reference/rate-limits) for the full table.
</Update>

<Update label="Apr 28, 2026" description="CLOB V2 is live on production">
  Polymarket's CLOB V2 upgrade is live on `https://clob.polymarket.com`.

  * **Production URL unchanged**: V2 now runs on the standard CLOB host. New integrations should use `https://clob.polymarket.com`.
  * **No V1 compatibility**: Legacy V1 SDKs and V1-signed orders are no longer supported on production.
  * **Open orders wiped**: Resting orders from before the cutover did not migrate and must be re-created with V2 signing.
  * **Migration guide**: See [Migrating to CLOB V2](/v2-migration) for the SDK, raw order signing, pUSD, and builder attribution changes.
</Update>

<Update label="Apr 21, 2026" description="Relayer API: POST /submit returns immediately without transactionHash">
  * **Faster `POST /submit` responses**: The Relayer's `POST /submit` endpoint now returns immediately with just `{ transactionID, state: "STATE_NEW" }`. The `transactionHash` field has been removed from the submit response to improve performance.
  * **How to get the hash**: Poll [`GET /transaction`](/api-reference/relayer/get-a-transaction-by-id) with the returned `transactionID` to retrieve the onchain `transactionHash` once the transaction has been broadcast.
</Update>

<Update label="Apr 17, 2026" description="CLOB V2: upgrades go live April 28 at ~11:00 UTC, with ~1 hour of downtime">
  Polymarket is shipping a coordinated upgrade: **new Exchange contracts, a rewritten CLOB backend, and a new collateral token (pUSD)**.

  **Exchange upgrades go live April 28, 2026 at \~11:00 UTC with \~1 hour of downtime.** All integrations must migrate to the V2 SDK before the cutover — there will be no backward compatibility after go-live.
  **Full walkthrough:** [Migrating to CLOB V2](/v2-migration). Follow [Discord](https://discord.gg/polymarket), Telegram, and [status.polymarket.com](https://status.polymarket.com) for the exact start time.

  **Historical pre-cutover note:** before go-live, integrations could test against `https://clob-v2.polymarket.com`. As of April 28, V2 runs on `https://clob.polymarket.com`.

  **What's changing**

  * New Exchange contracts (CTF Exchange V2 + Neg Risk CTF Exchange V2)
  * **pUSD** replaces USDC.e as the collateral token (standard ERC-20 on Polygon, backed by USDC, backing enforced onchain)
  * Order struct: `nonce`, `feeRateBps`, `taker` removed — `timestamp` (ms), `metadata`, `builder` added
  * Fees are now set at match time — no more `feeRateBps` on orders
  * Builder attribution is native via `builderCode` on orders (no more `builder-signing-sdk`)
  * EIP-712 Exchange domain version bumps from `"1"` to `"2"` (ClobAuth stays at `"1"`)

  **What you need to do**

  * Install the V2 SDK — [`@polymarket/clob-client-v2`](https://www.npmjs.com/package/@polymarket/clob-client-v2) or [`py-clob-client-v2`](https://pypi.org/project/py-clob-client-v2/) — and remove the legacy `clob-client` / `py-clob-client` packages
  * Update constructor from positional args to options object; rename `chainId` → `chain`
  * Remove `feeRateBps`, `nonce`, and `taker` from your order creation code
  * If you're a builder, copy your code from [Settings → Builder](https://polymarket.com/settings?tab=builder) and attach it to orders
  * If you sign orders without the SDK, update the `verifyingContract` and the signed Order fields — see [For API users](/v2-migration#for-api-users)
  * Plan for all open orders to be wiped at cutover

  **During the window:** Trading will be paused for \~1 hour on April 28 starting around 11:00 UTC. The SDK's hot-swap mechanism will auto-refresh the client when V2 goes live — no manual action needed if you're on the latest SDK.
</Update>

<Update label="Apr 13, 2026" description="Bridge API: added support link for bridging issues">
  * **Support contact**: Added a link to [our Bridge API provider's support](https://intercom.help/funxyz/en/articles/10732578-contact-us) (Fun.xyz) for failed, stuck, or compliance-held bridge transactions. See [Deposit Status](/trading/bridge/status).
</Update>

<Update label="Apr 10, 2026" description="New keyset pagination endpoints for markets and events">
  * **New endpoints**: Added `GET /markets/keyset` and `GET /events/keyset` for cursor-based pagination, replacing offset-based `GET /markets` and `GET /events`.
  * **How it works**: These use an opaque `after_cursor`/`next_cursor` token instead of `offset`, providing stable and efficient paging through large result sets. Same filters, same response shape per item — the only differences are the wrapper response (`{ "markets": [...], "next_cursor": "..." }`) and the rejection of `offset`.
  * **Migration**: The existing `GET /markets` and `GET /events` endpoints remain available but will be deprecated in a future release. New integrations should use the keyset variants.
</Update>

<Update label="Apr 9, 2026" description="GET /markets: closed defaults to false">
  * **`closed` default change**: The `closed` query parameter on `GET /markets` now defaults to `false`. Closed markets are excluded from results unless you explicitly pass `closed=true`.
</Update>

<Update label="Mar 31, 2026" description="REST API Fee Fields Update">
  * **Fee calculation source**: Fees should now be calculated using the `feeSchedule` object within a market.
</Update>

<Update label="Mar 30, 2026" description="Fee Structure V2">
  * **New fee categories**: Fees now apply to Crypto, Sports, Finance, Politics, Economics, Culture, Weather, Tech, Mentions, and Other / General markets with updated rates per category. Geopolitical and world events markets remain fee-free.
  * **Updated documentation**: [Fees](/trading/fees) and [Maker Rebates Program](/market-makers/maker-rebates).
</Update>

<Update label="Mar 17, 2026" description="March Madness: $2M+ in Liquidity Rewards">
  * **March Madness Liquidity Rewards**: Adding \$2M+ in liquidity rewards to both live and pregame markets.
  * **How it works**: Liquidity rewards are payments for placing competitive bids. Rewards are paid out based on the size of your orders, how close they are to the midpoint, and how consistently they are quoted relative to other liquidity providers. Orders must be active on the book for a minimum of **3.5 seconds** to be eligible.

  **Daily reward rates for markets (subject to change):**
  **48 hours before GameStartTime:**
  * \$7.5k for full game ML market
  * \$500 for 5 other markets (most recently created full game spread, most recently created full game total, 1st half ML, most recently created 1st half spread, most recently created 1st half total)

  **From game live to game completion (note: rewards are expressed in daily rates):**
  * \$60k for full game ML
  * \$4k for most recently created full game spread and most recently created full game total
  **From game live to halftime (note: rewards are expressed in daily rates):**

  * \$8k for 1st half ML, most recently created 1st half spread, most recently created 1st half total
  * **Markets**: [Browse March Madness markets](https://polymarket.com/sports/cbb/games)
  * **More details**: [Liquidity Rewards documentation](/market-makers/liquidity-rewards#march-madness)
</Update>

<Update label="Mar 1, 2026" description="Taker Fees & Maker Rebates: All Crypto Markets">
  * **Crypto market fees expansion**: Starting March 6, 2026, taker fees and maker rebates extend to all crypto markets including 1H, 4H, daily, and weekly. The same fee structure as existing crypto markets applies. Only new markets created after March 6 are affected.
  * **Updated documentation**: [Fees](/trading/fees) and [Maker Rebates Program](/market-makers/maker-rebates) updated to reflect all crypto market coverage.
</Update>

<Update label="Feb 12, 2026" description="5-Minute Crypto Markets">
  * **5-minute crypto markets**: Launched with taker fees enabled. Fees follow the same curve as 15-minute crypto markets, peaking at 1.56% at 50% probability.
  * **Maker Rebates**: Liquidity providers earn daily USDC rebates funded by taker fees, same as 15-minute crypto markets.
</Update>

<Update label="Feb 11, 2026" description="Taker Fees & Maker Rebates: NCAAB and Serie A">
  * **Sports market fees**: Taker fees to be enabled on NCAAB (college basketball) and Serie A markets on February 18, 2026.
  * **Per-market rebate calculation**: Rebates are now calculated per market, makers only compete with other makers in the same market.
  * **Updated documentation**: [Maker Rebates Program](/market-makers/maker-rebates) updated with sports fee tables and parameters.
</Update>

<Update label="Jan 28, 2026" description="Bridge API: Withdrawal Endpoint">
  * **Withdrawal Endpoint**: New `/withdraw` endpoint to bridge USDC.e from Polymarket to any supported chain and token.
  * **Multi-chain withdrawals**: Withdraw to EVM chains (Ethereum, Arbitrum, Base, etc.), Solana, and Bitcoin.
  * **Updated documentation**: Bridge API docs updated to reflect deposit and withdrawal functionality.
</Update>

<Update label="Jan 16, 2026" description="Docs Update: RTDS documentation">
  * RTDS docs updated to reflect RTDS supports **comments** and **crypto prices** only.
  * Removed legacy CLOB references and `clob_auth` from RTDS docs.
</Update>

<Update label="Jan 16, 2026" description="Docs Update: Maker Rebates Program">
  * **Maker Rebates Program**: Updated maker rebates program documentation to reflect updated fee categories, market eligibility, and rebate calculation methodology.
</Update>

<Update label="Dec 19, 2025" description="Updated /trades and /activity data endpoints">
  * Added `creator_id` field to trade and activity data responses.
  * `creator_id` represents the wallet address or user ID that created the order which resulted in the trade.
</Update>

<Update label="Dec 5, 2025" description="Neg Risk: Insurance policy markets">
  * **New market type**: Polymarket now supports insurance policy markets for Neg Risk. Insurance policy markets allow users to hedge risk within the Polymarket platform by purchasing insurance on any market.
  * **How it works**: Insurance policy markets operate similarly to standard markets, but with the ability to purchase insurance on an existing market to hedge your positions. See [Insurance Policy Markets](/concepts/insurance) for more details.
</Update>

<Update label="Nov 28, 2025" description="CLOB: Blocked Users Endpoint">
  * **New endpoint**: Added `GET /v2/.Blocklist` to retrieve the list of blocked users for a given API credential.
  * **New endpoint**: Added `POST /v2/Blocklist` to block a user from interacting with your orders.
  * **New endpoint**: Added `DELETE /v2/Blocklist/{wallet}` to unblock a previously blocked wallet address.
</Update>

<Update label="Nov 20, 2025" description="CLOB: Market Data API updates">
  * **New endpoint**: Added `GET /v2/groups/{group_id}/filtered-orderbook` with the following query parameters: `currency`, `ticksize`, `since`, and `limit` to receive an orderbook filtered by specified parameters.
  * **New endpoint**: Added `GET /v2/groups/{group_id}/markets` to get the markets associated with a specific group.
</Update>

<Update label="Nov 14, 2025" description="CLOB: Position Sweeping">
  * **Position Sweeping**: Users can now sweep their entire position in a given market. Position sweeping allows users to close their position in a market by posting a competitive order at the current market midpoint price.
  * **New endpoint**: Added `POST /v2/positions/sweep` to sweep a position in a given market.
  * **New endpoint**: Added `GET /v2/positions/sweep/{market_address}` to get the details of the sweep.
</Update>

<Update label="Oct 31, 2025" description="Bridge API: Updated Response Schema">
  * **Updated response schema**: Bridge API responses updated to include `source_chain`, `destination_chain`, `amount`, `status`, and `transaction_hash` fields for improved clarity.
</Update>

<Update label="Oct 24, 2025" description="Taker Fees & Maker Rebates: Tennis">
  * **Sports market fees**: Taker fees to be enabled on Tennis markets on October 28, 2025.
  * **Per-market rebate calculation**: Rebates are now calculated per market, makers only compete with other makers in the same market.
  * **Updated documentation**: [Maker Rebates Program](/market-makers/maker-rebates) updated with sports fee tables and parameters.
</Update>

<Update label="Oct 15, 2025" description="Updated /trades data endpoint">
  * **New `order_type` field**: The `order_type` field has been added to the trade object in the CLOB trades endpoint and the Data API `/trades` endpoint.
  * This field indicates whether the order was a market order or a limit order.
</Update>

<Update label="Oct 3, 2025" description="CLOB: Position Details Endpoint">
  * **New endpoint**: Added `GET /v2/positions/{market_address}` to retrieve detailed information about a user's position in a given market.
</Update>

<Update label="Sep 26, 2025" description="Maker Rebates: World Events markets fee-free">
  * **Maker Rebates**: Geopolitical and world events markets are now eligible for maker rebates. See [Maker Rebates Program](/market-makers/maker-rebates) for eligibility and rebate rates.
</Update>

<Update label="Sep 23, 2025" description="CLOB: New Order Type Endpoint">
  * **New endpoint**: `GET /order_type` returns the order types available for a given market.
</Update>

<Update label="Sep 15, 2025" description="Gamma API: New endpoint — GET /markets/activity">
  * **New endpoint**: Added `GET /markets/activity` for retrieving activity data for specific markets.
  * **New endpoint**: Added `GET /events/activity` for retrieving activity data for specific events.
  * **Note**: These endpoints have a rate limit of 1000 req / 10s.
</Update>

<Update label="Sep 15, 2025" description="Gamma API: GET /markets and GET /events deprecated">
  * **Important**: `GET /markets` and `GET /events` are now deprecated. Please use `GET /markets/activity` and `GET /events/activity` instead.
</Update>

<Update label="Sep 15, 2025" description="Liquidity Rewards updates">
  * **Liquidity Rewards changes**: Liquidity rewards have been updated for all markets.
  * **Minimum order lifetime**: Orders must now be active on the book for a minimum of **3.5 seconds** to be eligible for liquidity rewards.
  * **Reward payment timing**: Rewards are now paid out daily instead of weekly.
</Update>

<Update label="August 26, 2025" description="Updated /trades and /activity endpoints">
  * Reduced maximum values for query parameters on Data-API /trades and /activity:
    * `limit`: 500
    * `offset`: 1,000
</Update>

<Update label="August 21, 2025" description="Batch Orders Increase">
  * The batch orders limit has been increased from 5 -> 15. Read more about the batch orders functionality [here](/trading/orders/create).
</Update>

<Update label="July 23, 2025" description="Get Book(s) update">
  * We're adding new fields to the `get-book` and `get-books` CLOB endpoints to include key market metadata that previously required separate queries.
    * `min_order_size`
      * type: string
      * description: Minimum price increment.
    * `neg_risk`
      * type: boolean
      * description: Boolean indicating whether the market is neg\_risk.
    * `tick_size`
      * type: string
      * description: Minimum price increment.
</Update>

<Update label="June 3, 2025" description="New Batch Orders Endpoint">
  * We're excited to roll out a highly requested feature: **order batching**. With this new endpoint, users can now submit up to five trades in a single request. To help you get started, we've included sample code demonstrating how to use it. Please see [Create Orders](/trading/orders/create) for more details.
</Update>

<Update label="June 3, 2025" description="Change to /data/trades">
  * We're adding a new `side` field to the `MakerOrder` portion of the trade object. This field will indicate whether the maker order is a `buy` or `sell`, helping to clarify trade events where the maker side was previously ambiguous. For more details, refer to the MakerOrder object on the [Orders](/trading/orders/cancel) page.
</Update>

<Update label="May 28, 2025" description="Websocket Changes">
  * The 100 token subscription limit has been removed for the Markets channel. You can now subscribe to as many token IDs as needed for your use case.
  * New Subscribe Field `initial_dump`
    * Optional field to indicate whether you want to receive the initial order book state when subscribing to a token or list of tokens.
    * `default: true`
</Update>

<Update label="May 28, 2025" description="New FAK Order Type">
  We're excited to introduce a new order type soon to be available to all users: Fill and Kill (FAK). FAK orders behave similarly to the well-known Fill or Kill (FOK) orders, but with a key difference:

  * FAK will fill as many shares as possible immediately at your specified price, and any remaining unfilled portion will be canceled.
  * Unlike FOK, which requires the entire order to fill instantly or be canceled, FAK is more flexible and aims to capture partial fills if possible.
</Update>

<Update label="May 15, 2025" description="Increased API Rate Limits">
  All API users will enjoy increased rate limits for the CLOB endpoints.

  * CLOB - /books (website) (300req - 10s / Throttle requests over the maximum configured rate)
  * CLOB - /books (50 req - 10s / Throttle requests over the maximum configured rate)
  * CLOB - /price (100req - 10s / Throttle requests over the maximum configured rate)
  * CLOB markets/0x (50req / 10s - Throttle requests over the maximum configured rate)
  * CLOB POST /order - 500 every 10s (50/s) - (BURST) - Throttle requests over the maximum configured rate
  * CLOB POST /order - 3000 every 10 minutes (5/s) - Throttle requests over the maximum configured rate
  * CLOB DELETE /order - 500 every 10s (50/s) - (BURST) - Throttle requests over the maximum configured rate
  * DELETE /order - 3000 every 10 minutes (5/s) - Throttle requests over the maximum configured rate
</Update>