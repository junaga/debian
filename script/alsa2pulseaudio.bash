# `ALSA` to `PulseAudio` bridge

# The `PulseAudio` library is the modern standard for audio on Linux,
# but some older programs still expect the traditional `ALSA` library standard.
# This script installs `ALSA` and configures it to proxy into `PulseAudio`.
# This allows both modern and legacy, audio and microphone applications, to work seamlessly.

# `Windows Subsystem for Linux` creates `PulseAudio` sockets for audio and microphone.
#   /mnt/wslg/runtime-dir/PulseServer
#   /mnt/wslg/runtime-dir/PulseAudioRDPSink
#   /mnt/wslg/runtime-dir/PulseAudioRDPSource

# install ALSA and ALSA-to-PulseAudio bridge
sudo apt install -y libasound2 libasound2-plugins

# configure proxy into PulseAudio
cat > ~/.asoundrc <<ESC
pcm.!default {
  type pulse
}
ctl.!default {
  type pulse
}
ESC

# Record, and play, audio with ALSA
echo "HELLO, SAY SOMETHING TO THE MICROPHONE (5 seconds)..."
arecord -d 5 -f S16_LE -r 44100 -c 2 test.wav
aplay test.wav
rm test.wav
