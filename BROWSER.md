# Browser setup

Use Microsoft Playwright CLI as described in [ABC](agent/OP.md#abc---agent-browser-cli).
The installer removes Vercel agent-browser and installs `@playwright/cli`.

## Migration history

Commit `4ea7445cde6d111d5bcec53354700a56779371f5` replaced agent-browser on
2026-11-06 on `dev-abc-headless-default`. That branch was preserved separately
from `linux`; the host retained Playwright CLI while the active instructions
still described agent-browser. This change restores the migration on `linux`
without importing unrelated branch changes or historical browser experiments.

## Validation — 2026-11-15

Playwright CLI 0.1.23 passed headless and headed Chrome launch, accessibility
snapshots, reference-based fill/click, keyboard input, navigation, tabs,
JavaScript evaluation, Playwright scripting, screenshots, and persistent cookies
and localStorage across browser shutdown/restart. CDP attachment to a separately
running isolated Chrome passed; detaching left that browser running.

The Wikipedia example was also exercised with the current search-field reference.
Personal Chrome auto-discovery/approval, native password-manager prompts, real
CAPTCHAs and physical security keys are outside this automated validation.

Reproduction scripts, command outputs and screenshot are retained under
`/usr/local/env/ABC-test/smoke-validation/`. Run `python3 test.py` and
`python3 attach-test.py` there. Tests use isolated profiles and local fixtures;
the separate Wikipedia check requires Internet access.
