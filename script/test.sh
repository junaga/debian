# Audio and Mic
echo Test speak now
timeout 3 pw-record /tmp/test.wav
pw-play /tmp/test.wav

# Emoji in the Terminal
curl https://unicode.org/Public/emoji/latest/emoji-test.txt | grep "; fully-qualified" | head
