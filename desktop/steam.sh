#!/bin/bash

set -e

sudo apt update
sudo apt install steam-libs steam-libs-i386:i386

URL=https://repo.steampowered.com/steam/archive/stable/steam_latest.tar.gz

# install
# Valve's pressure-vessel runtime uses /usr as its container filesystem, so it
# cannot access Steam or HOME below /usr. The launcher exposes /usr/local at
# /home/junaga and Steam uses that alias.
# See https://github.com/ValveSoftware/steam-runtime/issues/288
sudo mkdir -p /home/junaga
mkdir -p /usr/local/lib/steam/steamapps /usr/local/lib/steamapps
cd /usr/local/lib/steam
curl "$URL" -o steam.tar
tar xf steam.tar --strip-components=1 steam-launcher/{bin_steam.sh,bootstraplinux_ubuntu12_32.tar.xz}
rm steam.tar

# configure
sed -i 's|DEFAULTSTEAMDIR="$STEAM_DATA_HOME/Steam"|DEFAULTSTEAMDIR="/home/junaga/lib/steam"|' bin_steam.sh

# Keep game data on the larger HOME filesystem. The launcher bind-mounts HOME
# at /home/junaga so pressure-vessel and Proton can access it outside /usr.
cat > steamapps/libraryfolders.vdf <<EOF
"libraryfolders"
{
  "0" { "path" "/home/junaga/lib" }
}
EOF

# launcher
cat > /usr/local/bin/steam <<'EOF'
#!/bin/bash
set -e
mountpoint -q /home/junaga || sudo mount --bind /usr/local /home/junaga
exec env HOME=/home/junaga /home/junaga/lib/steam/bin_steam.sh "$@"
EOF
chmod +x /usr/local/bin/steam
