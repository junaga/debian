# run this on the Home desktop
# then listen $PORT on the $VPS

VPS="brigade"
PORT="9222"
TAB="https://tiktok.com"

# start Chrome with CDP
google-chrome \
  --remote-debugging-address=localhost \
  --remote-debugging-port=$PORT \
  --user-data-dir=$HOME/.openclaw-chrome \
  & disown

# # Hello, World!
# curl http://localhost:$PORT/json/version

# Cursed Technique port tunnel
ssh -N -R localhost:$PORT:localhost:$PORT $VPS & disown

# now tell the agent to run
#   dev-browser --help
# and connect with
#   dev-browser --connect http://localhost:9222
