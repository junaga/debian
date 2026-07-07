set -a
. .env

# buy and register the domain
cf registrar registrations create --domain-name "$DOMAIN"
cf zones create --name "$DOMAIN"

# create a Cloudflare Pages resource
NAME="${DOMAIN//./-}"
cf pages projects create --name "$NAME"
cf pages projects domains create "$NAME" --name "$DOMAIN"

# deploy the site
wrangler pages deploy public --project-name "$NAME"
