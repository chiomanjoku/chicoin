# ChiCoin (CHI)

A simple fungible token written in Clarity and scaffolded with Clarinet. This token implements a minimal interface with initialization, transfers, and read-only views. No external trait dependencies are required for type-checking.

## Requirements
- Clarinet 3.9+ installed and available on your PATH
- Node.js (optional, for running the generated TypeScript tests)

## Project structure
```
.
├── Clarinet.toml
├── contracts
│   └── chicoin.clar
├── settings
│   ├── Devnet.toml
│   ├── Mainnet.toml
│   └── Testnet.toml
├── tests
│   └── chicoin.test.ts
└── README.md
```

## Contract overview
`contracts/chicoin.clar` exposes:
- initialize() → (ok true) | (err u100)
  - Mints the fixed INITIAL-SUPPLY to the first caller. Can be called only once.
- transfer(amount uint, recipient principal) → (ok true) | (err u101 | u102)
  - Moves tokens from `tx-sender` to `recipient`.
- get-name() → (ok "Chi Coin")
- get-symbol() → (ok "CHI")
- get-decimals() → (ok u6)
- get-total-supply() → (ok uint)
- get-balance(who principal) → (ok uint)

Error codes:
- u100: already initialized
- u101: insufficient balance
- u102: zero amount not allowed

Token params:
- Name: Chi Coin
- Symbol: CHI
- Decimals: 6
- Initial supply: 100,000 CHI (represented as 100,000 × 10^6 on-chain)

## Quick start
From the project root:

- Check contracts
```sh
clarinet check
```

- Open a console and try the contract
```sh
clarinet console
```
Then in the REPL:
```clojure
;; Mint the initial supply to the caller once
(contract-call? .chicoin initialize)

;; Inspect supply
(contract-call? .chicoin get-total-supply)

;; Check my balance
(contract-call? .chicoin get-balance tx-sender)

;; Transfer 1 CHI (remember: 6 decimals => 1 CHI = u1000000)
(contract-call? .chicoin transfer u1000000 '<RECIPIENT-PRINCIPAL>)
```

- Run tests (optional)
```sh
npm install
npm test
```

## Development notes
- This example purposefully avoids importing the SIP-010 trait to keep `clarinet check` fast and self-contained. If you want strict interface conformance, add a local trait file and `impl-trait` accordingly.
- The token can only be initialized once. Adjust `INITIAL-SUPPLY`, decimals, or add admin/mint/burn logic as your application requires.

## Deployment
When ready, you can use Clarinet to publish the contract to a Stacks network (make sure your `settings/*.toml` are configured):
```sh
clarinet deployments generate
clarinet deployments apply --network testnet
```
