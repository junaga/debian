# Stripe

[stripe.com](https://stripe.com/) is financial infrastructure for businesses.

> Your ... financial operating system. [_--quote_](https://stripe.com/#:~:text=operating%20system)

## Operation

Prefer using the `stripe` CLI.

```sh
# install or update
stripe --version
npm view @stripe/cli version
npm --global install @stripe/cli

# manage login
stripe whoami
stripe login

# discover commands
stripe --help
stripe --map

# explore documentation
stripe docs --help
```

## Services

Stripe's cloud includes [53 services](https://stripe.com/products) (October 2026). Including:

- [Money Management](https://stripe.com/money-management/availability)
- [Global Payouts](https://docs.stripe.com/global-payouts)
- [Payment Links](https://docs.stripe.com/payment-links)

### Starting a company

[Atlas](https://stripe.com/atlas) forms a Delaware C corporation or LLC with a US tax identifier and standard legal documents. Formation costs **$500**, including the first year of registered-agent service; that service then costs **$100/year**. Taxes and other filings are separate. Atlas includes $2,500 in Stripe fee credits for one year and [partner offers](https://support.stripe.com/questions/stripe-atlas-perks-partners) such as AWS ($5,000) and Azure ($5,000+), subject to eligibility and expiry. For VC-funded startups, see [Stripe Startups](https://support.stripe.com/questions/stripe-startups-program-faq).

## History

Bank settlement → card network → link checkout.

1609 — The Bank of Amsterdam let customers pay by **transferring balances** instead of exchanging coins ([history](https://www.dnb.nl/en/publications/research-publications/working-paper-2020/696-an-early-stablecoin-the-bank-of-amsterdam-and-the-governance-of-money/)).

1958 — BankAmericard, later Visa, helped customers use **one card across many merchants** ([history](https://www.visa.com.hk/en_HK/about-visa.html)). Visa's FY2025 payment volume equaled **≈12% of global GDP (our estimate)** ([annual report](https://annualreport.visa.com/financials/)).

2011 — Stripe launched its **payment cloud** for online checkout ([history](https://stripe.dev/blog/payment-api-design)). Its 2025 payment volume equaled **1.6% of global GDP** ([annual letter](https://stripe.com/annual-updates/2025)).

<!--
Visa estimate: $14.2T FY2025 payments volume / $118.485328T calendar-year 2025
world nominal GDP * 100 = 11.98%, rounded to approximately 12%.
Sources checked 2026-10-22:
- Visa FY2025 statistics: https://annualreport.visa.com/financials/default.aspx
- IMF DataMapper, NGDPD / WEOWORLD / 2025: 118485.328 billion current US dollars.
  https://www.imf.org/external/datamapper/api/v1/NGDPD/WEOWORLD?periods=2025
Visa's fiscal year ended 2025-09-30; the GDP figure covers the calendar year.
Payment volume is not GDP contribution.
-->
