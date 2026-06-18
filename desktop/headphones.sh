#!/usr/bin/env bash
set -euo pipefail

card=bluez_card.3C_B0_ED_A7_96_8D
sink=bluez_output.3C_B0_ED_A7_96_8D.1
mic=bluez_input.3C:B0:ED:A7:96:8D
builtin_mic=alsa_input.pci-0000_00_1f.3.analog-stereo

case "${1:-}" in
  stereo)
    pactl set-card-profile "$card" a2dp-sink
    sleep 0.3
    pactl set-default-sink "$sink"
    pactl set-default-source "$builtin_mic"
    ;;
  microphone)
    pactl set-card-profile "$card" headset-head-unit
    for _ in {1..20}; do
      pactl list sources short | grep -Fq "$mic" && break
      sleep 0.1
    done
    pactl set-default-sink "$sink"
    pactl set-default-source "$mic"
    ;;
  *)
    echo "Usage: headphones.sh stereo|microphone" >&2
    exit 2
    ;;
esac
