DIR="$(dirname $0)"
WORK="$1"
PROVIDER="openai-codex" # ChatGPT Codex OAuth

mkdir -p $WORK
cp -r $DIR/home/. $WORK/.

# Install gateway and login provider
openclaw onboard\
    --accept-risk\
    --flow quickstart\
    --workspace $WORK\
    --auth-choice $PROVIDER\
    --skip-ui;

# allow `$ apt install` from tui, web, discord ...
openclaw config set tools.elevated.enabled true
openclaw config set tools.elevated.allowFrom.'*' '["*"]'

# enable browser and other tools
openclaw config set tools.profile full

# stop printing the welcome text in TUI
openclaw config set cli.banner.taglineMode off

openclaw gateway restart
