# run this on your desktop system
# then listen to $PORT on the server system

DATA="$HOME/google-chrome-openclaw"
PROFILE="${1:-Default}" # "Default" profile
USER_HOST="root@46.224.172.45" # SOS Brigade
PORT="${2:-9222}" # Chrome DevTools Protocol

google-chrome \
  --user-data-dir="$DATA" \
  --profile-directory="$PROFILE" \
  \
  --mute-audio \
  --use-fake-device-for-media-stream \
  --no-default-browser-check \
  --no-first-run \
  \
  --remote-debugging-address="localhost" \
  --remote-debugging-port=$PORT \
  & disown

sleep 1

# Hello, CDP!
curl http://localhost:$PORT/json/version

# Cursed Technique port tunnel
ssh -N -R localhost:$PORT:localhost:$PORT $USER_HOST & disown

# on the server:
# dev-browser --connect http://localhost:9222
