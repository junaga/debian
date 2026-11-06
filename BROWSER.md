# Browser setup

## Requirements

- Add a research profile, separate from personal `Default`; decide how it retains passwords and passkeys.
- Use Microsoft's Playwright CLI with an explicit persistent user-data directory for headless work. Use live Chrome for signups and failed headless flows. Generate/save passwords there, never in the CLI or separate files. Keep automated sessions on dedicated tabs and select the profile explicitly.
- Arrange required human steps for new credentials and Terms before starting a signup.

## Observed problems

- On 2026-11-07, Playwright CLI passed headless and headed launch, real Playwright scripting, and cookie/localStorage persistence across restarts. Attachment to personal Chrome initially hung; restarting Chrome with session restoration resolved it. Navigation, clicking, screenshots and detach then passed. This is a successful smoke test, not a long-term reliability guarantee. Native password-manager and physical passkey flows remain untested.

- A headless profile copy did not share live saved credentials. Intigriti rejected headless signup as bot-like; live signup worked.
- Before the Playwright CLI migration, remote debugging showed port 9222, but the previous CLI could not discover Chrome until a restart created `DevToolsActivePort`. Root cause unknown.
- Codex computer use was unavailable. Two Fing forms contain only alias emails and synthetic names; no accounts were created.

See [ABC](agent/OP.md#abc---agent-browser-cli), [browser-history backlog](BACKLOG.md#15-permanent-browser-history-without-losing-passkeys), and the separate [Chromium passkey issue](https://issues.chromium.org/issues/578720650).
