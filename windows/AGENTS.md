- When changing Windows registry settings from Codex, check for MSIX registry virtualization.

## Terminal

Use Windows Terminal Preview for now; track stable releases in
[BACKLOG.md](../BACKLOG.md#18-terminal-releases).

- **2025-05-31:** [SSH discovery (#18814)](https://github.com/microsoft/terminal/pull/18814)
  adds saved SSH hosts to the profile menu; currently available in Preview.
- **2026-02-17:** [Kitty keyboard protocol (#19817)](https://github.com/microsoft/terminal/pull/19817)
  distinguishes keys such as `Shift+Enter`, fixing our remote input issue; available in stable 1.25+.

### Discovery quirk

When applying the repository config, preserve locally generated `profiles.list`
entries: [Terminal treats their removal as deletion](https://github.com/microsoft/terminal/blob/v1.26.2734.0/src/cascadia/TerminalSettingsModel/CascadiaSettingsSerialization.cpp#L529-L555),
using GUID history in `state.json` to hide previously discovered hosts.
Keep the repository config independent of host names, but merge it with those local
entries; `matchProfiles` only filters profiles and cannot unhide them.
