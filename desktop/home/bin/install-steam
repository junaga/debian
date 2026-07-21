#!/bin/bash

set -e

sudo apt update
sudo apt install steam-libs steam-libs-i386:i386

URL=https://repo.steampowered.com/steam/archive/stable/steam_latest.tar.gz
ALIAS=/home/junaga

# install
# Valve's pressure-vessel cannot access Steam or HOME below /usr, so the
# launcher exposes /usr/local at /home/junaga.
# See https://github.com/ValveSoftware/steam-runtime/issues/288
sudo mkdir -p "$ALIAS"
mkdir -p "$HOME/lib/steam" "$HOME/.factorio/config"
cd "$HOME/lib/steam"
curl "$URL" -o steam.tar
tar xf steam.tar --strip-components=1 steam-launcher/{bin_steam.sh,bootstraplinux_ubuntu12_32.tar.xz}
rm steam.tar

# configure
sed -i "s|DEFAULTSTEAMDIR=\"\$STEAM_DATA_HOME/Steam\"|DEFAULTSTEAMDIR=\"$ALIAS/lib/steam\"|" bin_steam.sh

if test ! -e "$HOME/.factorio/config/config.ini"; then
    echo '; version=13' > "$HOME/.factorio/config/config.ini"
    echo '[graphics]' >> "$HOME/.factorio/config/config.ini"
    echo 'linux-preferred-video-driver=wayland' >> "$HOME/.factorio/config/config.ini"
fi

# launcher
cat > "$HOME/bin/steam" <<EOF
#!/bin/bash
set -e
mountpoint -q "$ALIAS" || sudo mount --bind "$HOME" "$ALIAS"
exec env HOME="$ALIAS" "$ALIAS/lib/steam/bin_steam.sh" "\$@"
EOF
chmod +x "$HOME/bin/steam"
