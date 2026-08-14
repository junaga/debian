#!/usr/bin/env bash

: "${DOMAIN:?Set DOMAIN to the domain being deployed}"

DOMAIN="${DOMAIN,,}"
NAME="${DOMAIN//./-}"

# Resource creation is intentionally best-effort. Existing resources may make
# these commands fail; without `set -e`, Bash continues and deploys the site.
cf registrar registrations create --domain-name "$DOMAIN"
cf zones create --name "$DOMAIN"
cf pages projects create --name "$NAME"
cf pages projects domains create "$NAME" --name "$DOMAIN"

# deploy every version of the site
wrangler pages deploy public --project-name "$NAME"
