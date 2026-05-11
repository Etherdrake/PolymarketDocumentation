# Deposit Wallets

> Create deposit wallets, execute wallet actions, and place POLY_1271 orders

Deposit wallets are the wallet path for **new API users**. Existing Safe and
Proxy users are unaffected and can continue using their current wallet setup.

For newly-created polymarket.com accounts using the deposit wallet flow, a
deposit wallet is automatically deployed for you.

<Info>
  This guide is for developers integrating directly with the APIs or SDKs. It
  does not change existing user balances, existing proxy wallets, or existing
  Safes.
</Info>

## Where Deposit Wallets Fit

| Area                 | Existing Safe/Proxy users           | New API user deposit wallet flow                 |
| -------------------- | ----------------------------------- | ------------------------------------------------ |
| Wallet type          | Existing proxy wallet or Safe       | Deposit wallet                                   |
| Wallet deployment    | Existing relayer Safe/proxy flow    | Relayer `WALLET-CREATE`                          |
| Deployment signature | Existing Safe/proxy deployment flow | No user signature in the `WALLET-CREATE` payload |
| Wallet calls         | Safe/proxy relayer transactions     | Relayer `WALLET` batches                         |
| Order signature type | `0`, `1`, or `2`                    | `3`, also called `POLY_1271`                     |
| Order maker          | EOA, proxy, or Safe                 | Deposit wallet address                           |
| Order signer field   | EOA for existing types              | Deposit wallet address                           |
| Signing key          | User EOA or session signer          | Deposit wallet owner or approved session signer  |

## Mental Model

A deposit wallet is a per-user ERC-1967 proxy deployed by a deposit wallet
factory. The wallet holds pUSD and conditional tokens on-chain.

The owner or session signer signs two different kinds of payloads:

1. A **deposit wallet Batch** for on-chain wallet calls. This is submitted to the
   relayer as a `WALLET` transaction.
2. A **CLOB order** with `signatureType = 3`. The CLOB validates this through
   ERC-1271 on the deposit wallet.

These signatures are not interchangeable. A `WALLET` batch uses a normal
65-byte EIP-712 signature over the `DepositWallet` `Batch` type. A CLOB order
uses an ERC-7739-wrapped `POLY_1271` signature and is longer than a normal ECDSA
signature.

## Integration Flow

<Steps>
  <Step title="Create or identify the owner signer">
    Use the EOA or session signer that will own the deposit wallet. This signer is
    also the key that signs deposit wallet batches and CLOB order payloads unless
    your session signer flow delegates signing elsewhere.
  </Step>

  <Step title="Deploy the deposit wallet">
    Submit a relayer `WALLET-CREATE` request. The body only needs the transaction
    type, owner address, and deposit wallet factory address.

    The deposit wallet address is deterministic. TypeScript relayer users can call
    `deriveDepositWalletAddress()`, and Python relayer users can call
    `get_expected_deposit_wallet()`. Other integrations should store the address
    returned by onboarding or derive it with the deterministic formula below.
  </Step>

  <Step title="Fund the deposit wallet">
    Transfer pUSD to the deposit wallet address. pUSD held by the EOA does not count
    as CLOB buying power for deposit wallet orders.
  </Step>

  <Step title="Approve trading contracts from the wallet">
    Approvals must be made **from the deposit wallet**, not from the owner EOA. Build
    ERC-20 or ERC-1155 approval calldata and submit it through a relayer `WALLET`
    batch.
  </Step>

  <Step title="Sync CLOB balances">
    After funding or changing allowances, call the CLOB balance allowance update
    endpoint through the SDK or API. The request must use `signature_type = 3`.
  </Step>

  <Step title="Place orders with POLY_1271">
    Initialize the CLOB client with the deposit wallet as the funder and
    `POLY_1271` as the signature type. Orders must have both `maker` and `signer`
    set to the deposit wallet address.
  </Step>
</Steps>

## SDK Users

Use a relayer client or the raw relayer API for wallet deployment and wallet
batches. Use the CLOB client for order signing, posting, cancelling, balances,
and account data.

<Tabs>
  <Tab title="TypeScript">
    Use the TypeScript clients with deposit wallet support:
    [@polymarket/builder-relayer-client](https://www.npmjs.com/package/@polymarket/builder-relayer-client)
    and
    [@polymarket/clob-client-v2](https://www.npmjs.com/package/@polymarket/clob-client-v2).

    ```bash theme={null}
    npm install @polymarket/builder-relayer-client @polymarket/clob-client-v2 @polymarket/builder-signing-sdk viem
    ```

    ### Deploy the Wallet

    ```typescript theme={null}
    import {
      BuilderApiKeyCreds,
      BuilderConfig,
    } from "@polymarket/builder-signing-sdk";
    import { RelayClient } from "@polymarket/builder-relayer-client";
    import { createWalletClient, Hex, http } from "viem";
    import { privateKeyToAccount } from "viem/accounts";
    import { polygon } from "viem/chains";

    const relayerUrl = process.env.RELAYER_URL!;
    const chainId = Number(process.env.CHAIN_ID ?? 137);
    const account = privateKeyToAccount(process.env.PRIVATE_KEY as Hex);
    const walletClient = createWalletClient({
      account,
      chain: polygon,
      transport: http(process.env.RPC_URL),
    });

    const builderCreds: BuilderApiKeyCreds = {
      key: process.env.BUILDER_API_KEY!,
      secret: process.env.BUILDER_SECRET!,
      passphrase: process.env.BUILDER_PASS_PHRASE!,
    };

    const builderConfig = new BuilderConfig({
      localBuilderCreds: builderCreds,
    });

    const relayer = new RelayClient(
      relayerUrl,
      chainId,
      walletClient,
      builderConfig,
    );

    const depositWalletAddress = await relayer.deriveDepositWalletAddress();
    const response = await relayer.deployDepositWallet();
    const confirmed = await response.wait();
    ```

    `deployDepositWallet()` submits a `WALLET-CREATE` transaction. It does not add a
    user signature to the deployment body.

    ### Execute a Wallet Batch

    ```typescript theme={null}
    import type { DepositWalletCall } from "@polymarket/builder-relayer-client";

    const calls: DepositWalletCall[] = [
      {
        target: process.env.PUSD_ADDRESS!,
        value: "0",
        data: approveCalldata,
      },
    ];

    const deadline = Math.floor(Date.now() / 1000 + 600).toString();
    const response = await relayer.executeDepositWalletBatch(
      calls,
      depositWalletAddress,
      deadline,
    );
    const confirmed = await response.wait();
    ```

    The TypeScript relayer client fetches the current `WALLET` nonce before signing
    and submitting the batch. The SDK signs the batch with this EIP-712 domain before
    submitting it to the relayer:

    ```typescript theme={null}
    {
      name: "DepositWallet",
      version: "1",
      chainId,
      verifyingContract: depositWalletAddress,
    }
    ```

    ### Trade From the Deposit Wallet

    ```typescript theme={null}
    import {
      AssetType,
      ClobClient,
      OrderType,
      Side,
      SignatureTypeV2,
    } from "@polymarket/clob-client-v2";

    const creds = {
      key: process.env.CLOB_API_KEY!,
      secret: process.env.CLOB_SECRET!,
      passphrase: process.env.CLOB_PASS_PHRASE!,
    };

    const clob = new ClobClient({
      host: process.env.CLOB_API_URL!,
      chain: chainId,
      signer: walletClient,
      creds,
      signatureType: SignatureTypeV2.POLY_1271,
      funderAddress: depositWalletAddress,
    });

    await clob.updateBalanceAllowance({ asset_type: AssetType.COLLATERAL });

    const order = await clob.createAndPostOrder(
      {
        tokenID: process.env.TOKEN_ID!,
        price: 0.5,
        size: 10,
        side: Side.BUY,
      },
      { tickSize: "0.01", negRisk: false },
      OrderType.GTC,
    );
    ```
  </Tab>

  <Tab title="Python">
    Use the Python builder relayer client with deposit wallet support:
    [py-builder-relayer-client](https://pypi.org/project/py-builder-relayer-client/).

    ```bash theme={null}
    pip install py-builder-relayer-client
    ```

    ### Deploy the Wallet

    ```python theme={null}
    import os

    from py_builder_relayer_client.client import RelayClient
    from py_builder_signing_sdk.config import BuilderApiKeyCreds, BuilderConfig

    builder_config = BuilderConfig(
        local_builder_creds=BuilderApiKeyCreds(
            key=os.environ["BUILDER_API_KEY"],
            secret=os.environ["BUILDER_SECRET"],
            passphrase=os.environ["BUILDER_PASS_PHRASE"],
        )
    )

    relayer = RelayClient(
        os.environ["RELAYER_URL"],
        int(os.environ.get("CHAIN_ID", "137")),
        os.environ["PRIVATE_KEY"],
        builder_config,
    )

    deposit_wallet = relayer.get_expected_deposit_wallet()
    response = relayer.deploy_deposit_wallet()
    confirmed = response.wait()
    ```

    `get_expected_deposit_wallet()` derives the deterministic wallet address from
    the signer and the chain's deposit wallet configuration.

    ### Execute a Wallet Batch

    ```python theme={null}
    import time

    from py_builder_relayer_client.models import DepositWalletCall, TransactionType

    nonce_payload = relayer.get_nonce(
        relayer.signer.address(),
        TransactionType.WALLET.value,
    )
    wallet_nonce = str(nonce_payload["nonce"])

    call = DepositWalletCall(
        target=os.environ["PUSD_ADDRESS"],
        value="0",
        data=approve_calldata,
    )

    response = relayer.execute_deposit_wallet_batch(
        calls=[call],
        wallet_address=deposit_wallet,
        nonce=wallet_nonce,
        deadline=str(int(time.time()) + 600),
    )
    confirmed = response.wait()
    ```

    The Python relayer client mirrors the TypeScript wire format for `WALLET-CREATE`
    and `WALLET` requests, while keeping builder API key auth in the Python client.

    ### Trade From the Deposit Wallet

    Use the Python CLOB client with deposit wallet order support:
    [py-clob-client-v2](https://pypi.org/project/py-clob-client-v2/).

    ```bash theme={null}
    pip install py-clob-client-v2
    ```

    ```python theme={null}
    import os

    from py_clob_client_v2 import (
        ApiCreds,
        AssetType,
        BalanceAllowanceParams,
        ClobClient,
        OrderArgs,
        OrderType,
        PartialCreateOrderOptions,
        Side,
        SignatureTypeV2,
    )

    creds = ApiCreds(
        api_key=os.environ["CLOB_API_KEY"],
        api_secret=os.environ["CLOB_SECRET"],
        api_passphrase=os.environ["CLOB_PASS_PHRASE"],
    )

    clob = ClobClient(
        host=os.environ["CLOB_API_URL"],
        chain_id=int(os.environ.get("CHAIN_ID", "137")),
        key=os.environ["PRIVATE_KEY"],
        creds=creds,
        signature_type=SignatureTypeV2.POLY_1271,
        funder=deposit_wallet,
    )

    clob.update_balance_allowance(
        BalanceAllowanceParams(
            asset_type=AssetType.COLLATERAL,
            signature_type=SignatureTypeV2.POLY_1271,
        )
    )

    response = clob.create_and_post_order(
        order_args=OrderArgs(
            token_id=os.environ["TOKEN_ID"],
            price=0.50,
            size=10,
            side=Side.BUY,
        ),
        options=PartialCreateOrderOptions(tick_size="0.01", neg_risk=False),
        order_type=OrderType.GTC,
    )
    ```
  </Tab>

  <Tab title="Rust">
    ### Deploy the Wallet and Execute Wallet Batches

    The Rust SDK supports the CLOB order path for deposit wallets. It does not
    include a builder relayer client. Use the TypeScript or Python relayer client
    above, or the raw API flow below, to submit `WALLET-CREATE` and `WALLET`
    transactions.

    Use the Rust CLOB client with deposit wallet support:
    [polymarket_client_sdk_v2](https://crates.io/crates/polymarket_client_sdk_v2).

    ```bash theme={null}
    cargo add polymarket_client_sdk_v2 --features clob
    ```

    Once the deposit wallet is deployed, funded, and approved, pass the deposit
    wallet address as the Rust CLOB client funder.

    ### Trade From the Deposit Wallet

    ```rust theme={null}
    use std::str::FromStr as _;

    use polymarket_client_sdk_v2::auth::{LocalSigner, Signer as _};
    use polymarket_client_sdk_v2::clob::types::request::UpdateBalanceAllowanceRequest;
    use polymarket_client_sdk_v2::clob::types::{AssetType, OrderType, Side, SignatureType};
    use polymarket_client_sdk_v2::clob::{Client, Config};
    use polymarket_client_sdk_v2::types::{Address, Decimal, U256};
    use polymarket_client_sdk_v2::{POLYGON, PRIVATE_KEY_VAR};

    let host = std::env::var("CLOB_API_URL")?;
    let token_id = U256::from_str(&std::env::var("TOKEN_ID")?)?;
    let deposit_wallet = Address::from_str(&std::env::var("DEPOSIT_WALLET")?)?;
    let signer =
        LocalSigner::from_str(&std::env::var(PRIVATE_KEY_VAR)?)?.with_chain_id(Some(POLYGON));

    let client = Client::new(&host, Config::default())?
        .authentication_builder(&signer)
        .funder(deposit_wallet)
        .signature_type(SignatureType::Poly1271)
        .authenticate()
        .await?;

    client
        .update_balance_allowance(
            UpdateBalanceAllowanceRequest::builder()
                .asset_type(AssetType::Collateral)
                .build(),
        )
        .await?;

    let _response = client
        .limit_order()
        .token_id(token_id)
        .side(Side::Buy)
        .price(Decimal::from_str("0.50")?)
        .size(Decimal::from_str("10")?)
        .order_type(OrderType::GTC)
        .build_sign_and_post(&signer)
        .await?;
    ```

    The Rust client sets `signatureType = 3` and builds the wrapped ERC-1271 order
    signature when `SignatureType::Poly1271` and a deposit wallet funder are
    configured.
  </Tab>
</Tabs>

## Raw API Integration

### Deposit Wallet Factory

The factory is configured per chain. Use the relayer's `GET /config` endpoint to
retrieve the current factory address.

```json
{
  "deposit_wallet_factory": "0x..."
}
```

### Deriving the Deposit Wallet Address

The wallet address is deterministic. Use the salt `0x0000000000000000000000000000000000000000000000000000000000000000`.

```
depositWallet = factory.computeAddress(salt, initCode)
```

Where `initCode` is the ERC-1967 proxy initialization code. Use the relayer client's
`deriveDepositWalletAddress()` method or `get_expected_deposit_wallet()` helper.

### WALLET-CREATE

```json
{
  "transactionType": "WALLET-CREATE",
  "owner": "0x...",
  "factory": "0x..."
}
```

No user signature is required. The relayer signs and submits the transaction.

### WALLET

```json
{
  "transactionType": "WALLET",
  "calls": [
    {
      "target": "0x...",
      "value": "0",
      "data": "0x..."
    }
  ],
  "nonce": "123",
  "deadline": "1714000000"
}
```

The batch is signed with a standard EIP-712 `DepositWallet.Batch` domain:

```typescript theme={null}
{
  name: "DepositWallet",
  version: "1",
  chainId,
  verifyingContract: depositWalletAddress,
}
```

The relayer signs and submits on your behalf.

## Next Steps

<CardGroup cols={2}>
  <Card title="Builder Program" icon="hammer" href="/builders/overview">
    Overview of the Builder Program and benefits
  </Card>

  <Card title="Builder Fees" icon="dollar" href="/builders/fees">
    How builder fees work and how to set rates
  </Card>

  <Card title="pUSD" icon="coin" href="/concepts/pusd">
    The collateral token powering Polymarket trading
  </Card>

  <Card title="Migration Guide" icon="arrow-right" href="/v2-migration">
    Full V2 migration guide
  </Card>
</CardGroup>