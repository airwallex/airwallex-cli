# Airwallex CLI

![Version](https://img.shields.io/badge/version-0.5.0-orange)

The Airwallex CLI helps you manage your Airwallex account right from the terminal.

**With the CLI, you can:**

- Inspect balances, beneficiaries, transfers, and conversions
- Create and manage billing customers, products, prices, and subscriptions
- Issue cards, manage cardholders, and tail issuing transactions

## Installation

macOS and Linux.

```sh
curl -fsSL https://static.airwallex.com/developer-tools/airwallex-cli/install.sh | sh
```

Or, if you have Node installed:

```sh
npm install -g @airwallex/cli
```

Pick one. If you already installed with curl, that copy stays ahead of the npm
one on your `PATH` — check with `which -a airwallex`, and remove it with:

```sh
curl -fsSL https://static.airwallex.com/developer-tools/airwallex-cli/install.sh | sh -s -- --uninstall
```

## Quickstart

```sh
# Complete flow to provide secure access to your Airwallex account
airwallex auth login --prod

# Run `--help` for detailed information about CLI commands
airwallex [command] --help
```

## Commands

- `auth` — sign in and inspect the current OAuth session
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

## Important Notice

> **Beta Software.** This CLI tool is provided on an "as-is" basis for use with Airwallex APIs. By downloading and using this software, you acknowledge that:

- **Ownership.** This CLI tool and installation script are proprietary software. All rights are reserved by Airwallex. You may not redistribute, modify, or reverse-engineer this software.
- **Beta Software.** This is a pre-release beta version. It is actively developed and may contain bugs or breaking changes.
- **No Warranty.** THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL AIRWALLEX BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY ARISING FROM THE USE OF THIS SOFTWARE.

## Feedback

Got feedback? Open an issue or run `airwallex feedback`.
