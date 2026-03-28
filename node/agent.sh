# ChatGPT Codex OAuth
PROVIDER="openai-codex"

# Agent workspace
mkdir -p ~/dev/

# Install gateway and login provider
openclaw onboard\
    --accept-risk\
    --flow quickstart\
    --workspace ~/dev/\
    --auth-choice $PROVIDER;

# allow `$ apt install` from tui, web, discord ...
openclaw config set tools.elevated.enabled true
openclaw config set tools.elevated.allowFrom.'*' '["*"]'

# hide the welcome text in TUI
openclaw config set cli.banner.taglineMode off

openclaw gateway restart
