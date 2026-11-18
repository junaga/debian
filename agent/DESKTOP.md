## `ISD` - Internet Service Defaults

Treat essential Internet services as part of the operating environment. Choose a
trusted default for each capability and reuse it across desktop and agent tools.

- **Time.** Prefer UTC throughout. Follow [LANG](LANG.md#timestamp) for timestamp
  formatting.
- **Weather.** Query Google Weather API for the requested location and report
  current conditions or a seven-day forecast. Report feels-like temperature in
  Celsius.
- **WAN quality.** Run `cloudflare-speedtest` on the host being diagnosed with
  configured Cloudflare TURN credentials. Report latency, upload and download
  speeds, packet loss, and the WAN health score from its JSON output.
