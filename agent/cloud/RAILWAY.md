# Railway

Railway hosts containers: workspace → project → service.

Prefer the `railway` CLI.

```sh
railway --help
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
