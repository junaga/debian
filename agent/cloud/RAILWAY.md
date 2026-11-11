# Railway

Railway hosts containers: workspace → project → service.

Prefer the `railway` CLI.

Before deploying, read the relevant official documentation using the
[LLM index](https://docs.railway.com/llms.txt) or
[full documentation](https://docs.railway.com/llms-full.txt); CLI help alone
does not establish platform constraints. `railway docs` prints these URLs in
non-interactive mode rather than providing bundled documentation.

```sh
railway --help
railway docs                  # discover official documentation URLs
railway login                 # authenticate
railway link                  # select project and service locally
railway status                # check the current target
railway up                    # deploy local source
railway logs                  # inspect deployment logs
railway ssh                   # enter the container
railway restart --yes         # restart without rebuilding
```

Inside a Railway container, supplied variables select the CLI target; authentication still requires login or a configured token.

```sh
printenv RAILWAY_PROJECT_ID RAILWAY_ENVIRONMENT_ID RAILWAY_SERVICE_ID
```
