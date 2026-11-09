## `DRR` - Domain Resource Record

Record each domain in `$WORK/doc/host/$DOMAIN.env`.

`cf` is the Cloudflare CLI.

| Field | Value |
| --- | --- |
| `DRR` | Date checked: `YYYY-MM-DD`. |
| `DOMAIN` | Domain name. |
| `OWNER` | Legal registrant. |
| `EMAIL` | Administrative contact email. |
| `REG_URL` or `REG_CLI` | Registrar management URL or CLI command. |
| `DNS_URL` or `DNS_CLI` | DNS management URL or CLI command. |
| `FEE` | Annual renewal price including tax and currency. |

Keep this order; use `unknown` for unverified values. Archive evidence and
previous versions in dated jobs. Work in `$WORK/PLAN.md` or `$WORK/BACKLOG.md`.

```sh
DRR="2026-11-09"
DOMAIN="jsbauelemente.de"
OWNER="J.S. Verkauf und Montage von Bauelementen"
EMAIL="hermann@stanew.name"
REG_URL="https://transit.secure.denic.de/"
DNS_CLI="cf dns records list -z jsbauelemente.de"
FEE="79 EUR"
```
