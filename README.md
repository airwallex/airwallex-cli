# Airwallex CLI

![GitHub release (latest by date)](https://img.shields.io/github/v/release/airwallex/airwallex-cli)

The Airwallex CLI helps you manage your Airwallex account right from the terminal.

**With the CLI, you can:**

- Inspect balances, beneficiaries, transfers, and conversions
- Create and manage billing customers, products, prices, and subscriptions
- Issue cards, manage cardholders, and tail issuing transactions

## Installation

Airwallex CLI is available for macOS and Linux as a single self-contained binary.

Auto-detects your OS and architecture, installs to `~/.local/bin/airwallex`:

```sh
curl -fsSL https://raw.githubusercontent.com/airwallex/airwallex-cli/master/install.sh | sh
```

## Quickstart

```sh
# Complete flow to provide secure access to your Airwallex account
airwallex auth login --prod

# Run `--help` for detailed information about CLI commands
airwallex [command] --help
```

## Commands

- `auth` — sign in and inspect the current session
- `balances` — view balance activity and totals
- `beneficiaries`, `beneficiary-schema` — manage payout beneficiaries
- `billing-customers`, `billing-checkouts`, `billing-transactions` — billing
- `cards`, `cardholders`, `issuing-transactions` — issuing
- `conversions`, `conversion-amendments`, `conversion-rates`, `quotes` — FX
- `invoices`, `credit-notes`, `coupons`, `prices`, `products`, `subscriptions`, `meters`, `usage-events` — billing & catalog
- `payment-intents`, `payment-links`, `payment-disputes`, `payment-sources`, `payment-customers`, `refunds` — payments
- `transfers`, `global-accounts` — money movement
- `spend-bills`, `spend-expenses`, `spend-purchase-orders`, `spend-vendors`, `reimbursement-reports`, `financial-reports` — spend & finance
- `feedback` — report issues or suggestions

## Documentation

For a full reference, see the [Airwallex API docs](https://www.airwallex.com/docs/api).

## Feedback

Got feedback? Open an issue or run `airwallex feedback`.

