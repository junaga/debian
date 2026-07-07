#!/usr/bin/env bash
set -euo pipefail

VERSION="${DISCORD_EXPORT_VERSION:-2.47.3}"
ARCHIVE="DiscordChatExporter.Cli.linux-x64.zip"
URL="https://github.com/Tyrrrz/DiscordChatExporter/releases/download/${VERSION}/${ARCHIVE}"
ZIP="/tmp/discord-export.zip"
INSTALL_DIR="$HOME/lib/discord-export"
BIN_DIR="$HOME/bin"

mkdir -p "$BIN_DIR" "$INSTALL_DIR"
curl -fsSL -o "$ZIP" "$URL"
unzip -oq "$ZIP" -d "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/DiscordChatExporter.Cli"
ln -sf "$INSTALL_DIR/DiscordChatExporter.Cli" "$BIN_DIR/discord-export"

"$BIN_DIR/discord-export" --version
