# Home desktop: Chrome headful + remote debugging
# VPS: OpenClaw attaches via custom CDP endpoint
# run this script on Home, it connects to VPS through SSH

VPS="main"
PORT="9222"
TAB="https://youtube.com"

# start browser
google-chrome \
  --remote-debugging-address=127.0.0.1 \
  --remote-debugging-port=$PORT \
  --user-data-dir=$HOME/.openclaw-chrome-profile & disown

# Hello, World!
# this is the Browser API. called CDP _Chrome DevTools Protocol_
curl http://127.0.0.1:$PORT/json/version

# map port
ssh -N -R 127.0.0.1:$PORT:127.0.0.1:$PORT $VPS & disown

# register
ssh "$VPS" 'python3 - <<'"'"'PY'"'"'
import json, pathlib

p = pathlib.Path("/usr/local/.openclaw/openclaw.json")
cfg = json.loads(p.read_text())

cfg.setdefault("browser", {})
cfg["browser"]["enabled"] = True
cfg["browser"]["defaultProfile"] = "home"
cfg["browser"].setdefault("profiles", {})
cfg["browser"]["profiles"]["home"] = {
    "cdpUrl": "http://127.0.0.1:9222",
    "attachOnly": True,
    "color": "#00AA00"
}

p.write_text(json.dumps(cfg, indent=2) + "\n")
print("updated", p)
PY'
<

ssh $VPS "openclaw gateway restart"

# open a tab
ssh $VPS "openclaw browser --browser-profile home open $TAB"
