#!/bin/bash

sudo apt update
sudo apt install steam-libs steam-libs-i386:i386

URL=https://repo.steampowered.com/steam/archive/stable/steam_latest.tar.gz

# install
mkdir -p /usr/local/lib/steam/steamapps
cd /usr/local/lib/steam
curl "$URL" -o steam.tar
tar xf steam.tar --strip-components=1 steam-launcher/{bin_steam.sh,bootstraplinux_ubuntu12_32.tar.xz}
rm steam.tar

# configure
sed -i 's|DEFAULTSTEAMDIR="$STEAM_DATA_HOME/Steam"|DEFAULTSTEAMDIR="/usr/local/lib/steam"|' bin_steam.sh

cat > steamapps/libraryfolders.vdf <<'EOF'
"libraryfolders"
{
  "0" { "path" "/usr/local/lib" }
}
EOF

# link
ln -s /usr/local/lib/steam/bin_steam.sh /usr/local/bin/steam
