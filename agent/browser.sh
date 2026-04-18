# run this on the Home desktop
# then listen $PORT on the $HOST server

PROFILE="Default"
HOST="46.224.172.45" # SOS Brigade
# PORT="2048" # spider
PORT="2049" # junaga
# PORT="2050"

# start Chrome with CDP
# media is faked/muted to avoid using real mic/speakers
google-chrome \
  --profile-directory="Default" \
  --remote-debugging-address=localhost \
  --remote-debugging-port=$PORT \
  --use-fake-device-for-media-stream \
  --mute-audio \
  & disown

# Hello, CDP!
# curl http://localhost:$PORT/json/version

# Cursed Technique port tunnel
ssh -N -R localhost:$PORT:localhost:$PORT $HOST & disown

# on the server:
# dev-browser --connect http://localhost:9222
