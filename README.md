# Airwallex CLI

![Version](https://img.shields.io/badge/version-0.4.0-orange)

The Airwallex CLI helps you manage your Airwallex account right from the terminal.

**With the CLI, you can:**

- Inspect balances, beneficiaries, transfers, and conversions
- Create and manage billing customers, products, prices, and subscriptions
- Issue cards, manage cardholders, and tail issuing transactions

## Installation

Airwallex CLI is available for macOS and Linux as a single self-contained binary.

Auto-detects your OS and architecture, verifies the SHA256 checksum, and installs to `~/.local/bin/airwallex`:

```sh
curl -fsSL https://static.airwallex.com/developer-tools/airwallex-cli/install.sh | sh
```

Environment variables:

| Variable | Description |
|----------|-------------|
| `AIRWALLEX_VERSION` | Pin a specific release tag (e.g. `v0.1.0`). Defaults to the version bundled in the installer script. |
| `AIRWALLEX_INSTALL_DIR` | Install location. Defaults to `$HOME/.local/bin`. |
| `AIRWALLEX_SKIP_CHECKSUM` | **Local development only.** Set to `1` to bypass SHA256 verification. Never use this in production or CI. |

Exit codes: `0` success, `1` generic failure, `2` unsupported platform, `3` checksum mismatch, `4` network failure.

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

## Important Notice

> **Beta Software.** This CLI tool is provided on an "as-is" basis for use with Airwallex APIs. By downloading and using this software, you acknowledge that:

- **Ownership.** This CLI tool and installation script are proprietary software. All rights are reserved by Airwallex. You may not redistribute, modify, or reverse-engineer this software.
- **Beta Software.** This is a pre-release beta version. It is actively developed and may contain bugs or breaking changes.
- **No Warranty.** THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL AIRWALLEX BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY ARISING FROM THE USE OF THIS SOFTWARE.

## Feedback

Got feedback? Open an issue or run `airwallex feedback`.
