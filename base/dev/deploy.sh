#!/usr/bin/env bash

set -euo pipefail

: "${DOMAIN:?Set DOMAIN to the domain being deployed}"

DOMAIN="${DOMAIN,,}"
NAME="${DOMAIN//./-}"

# create resources that do not exist yet
cf registrar registrations get "$DOMAIN" >/dev/null 2>&1 ||
	cf registrar registrations create --domain-name "$DOMAIN"

cf zones list --name "$DOMAIN" | jq -e 'length > 0' >/dev/null ||
	cf zones create --name "$DOMAIN"

cf pages projects get "$NAME" >/dev/null 2>&1 ||
	cf pages projects create --name "$NAME" --production-branch main

cf pages projects domains get "$DOMAIN" --project-name "$NAME" >/dev/null 2>&1 ||
	cf pages projects domains create "$NAME" --name "$DOMAIN"

# deploy every version of the site
wrangler pages deploy public --project-name "$NAME"
