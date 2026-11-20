# Exa

Exa searches the public web and retrieves page content. Its APIs also offer
agent research, monitors, and Websets. [API documentation](https://exa.ai/docs/llms.txt)

## Operation

Use the intended Exa team in the dashboard. Create an API key for the team's
enabled product endpoints and store it as `EXA_API_KEY` in `~/.env` (mode
`0600`). Load the key into the calling process and send it in the `x-api-key`
header. Keep the key out of the repository. Team Management uses a separate
service account key and must be enabled for the team.
[API keys dashboard](https://dashboard.exa.ai/api-keys) · [Team Management](https://exa.ai/docs/reference/team-management/create-api-key)

From a Bash shell with `EXA_API_KEY` loaded, verify access with one search.

```bash
: "${EXA_API_KEY:?Load EXA_API_KEY from ~/.env first}"
printf 'x-api-key: %s\n' "$EXA_API_KEY" |
  curl --silent --show-error --fail-with-body --header @- \
    --header 'Content-Type: application/json' \
    --data '{"query":"Exa API documentation","numResults":1}' \
    https://api.exa.ai/search
```

## Search public X posts

- Use `includeDomains` with `x.com` and `twitter.com` to discover indexed
  public posts. Use `startPublishedDate` and `endPublishedDate` to bound
  results by publication date. A prefix such as `x.com/handle/status/`
  can narrow results by URL. Exa deprecated the `tweet` category.
  [Search reference](https://exa.ai/docs/reference/search) · [Changelog](https://exa.ai/docs/changelog#july-23-2026)
- Use the X API for author queries with `from:`, paginated historical search,
  and structured engagement via `tweet.fields=public_metrics`.
  [X Search API](https://docs.x.com/x-api/posts/search/introduction)
