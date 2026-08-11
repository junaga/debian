#!/usr/bin/env bash

set -euo pipefail

: "${DOMAIN:?Set DOMAIN to the domain being deployed}"

DOMAIN="${DOMAIN,,}"
NAME="${DOMAIN//./-}"

resource_exists() {
	local missing="$1"
	local output

	shift
	if output="$("$@" 2>&1)"; then
		return 0
	fi

	if [[ "$output" == *"$missing"* ]]; then
		return 1
	fi

	echo "$output" >&2
	return 2
}

listed() {
	local field="$1"
	local value="$2"

	jq -e --arg field "$field" --arg value "$value" '
		if type != "array" then error("expected a JSON array")
		else any(.[]; .[$field] == $value)
		end
	' >/dev/null
}

# register the domain once
if resource_exists "[10000] Domain not found" \
	cf registrar registrations get "$DOMAIN"; then
	echo "$DOMAIN is already registered."
else
	STATUS="$?"
	(( STATUS == 1 )) || exit "$STATUS"

	CHECK="$(cf registrar domain-check --domains "$DOMAIN")"
	jq -e '
		.domains[0].registrable == true and
		.domains[0].tier != "premium"
	' <<< "$CHECK" >/dev/null || {
		echo "$CHECK" >&2
		echo "$DOMAIN is not available for standard registration." >&2
		exit 1
	}

	cf registrar registrations create --domain-name "$DOMAIN"
fi

# create the zone once
ZONES="$(cf zones list --name "$DOMAIN")"
if listed name "$DOMAIN" <<< "$ZONES"; then
	echo "$DOMAIN already has a Cloudflare zone."
else
	STATUS="$?"
	(( STATUS == 1 )) || exit "$STATUS"
	cf zones create --name "$DOMAIN"
fi

# create the Cloudflare Pages resources once
if resource_exists "[8000007] Project not found" \
	cf pages projects get "$NAME"; then
	echo "$NAME Pages project already exists."
else
	STATUS="$?"
	(( STATUS == 1 )) || exit "$STATUS"
	cf pages projects create --name "$NAME" --production-branch main
fi

if resource_exists "[8000021] The domain you have requested does not exist" \
	cf pages projects domains get "$DOMAIN" --project-name "$NAME"; then
	echo "$DOMAIN is already attached to $NAME."
else
	STATUS="$?"
	(( STATUS == 1 )) || exit "$STATUS"
	cf pages projects domains create "$NAME" --name "$DOMAIN"
fi

# deploy every version of the site
wrangler pages deploy public --project-name "$NAME"
