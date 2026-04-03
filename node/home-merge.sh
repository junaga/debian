# Modern Linux $HOME is fucked beyond repair:
# - dotdirs
# - package managers
# - non-sudo installations
# - XDG
#   - Config
#   - Cache
#   - Data
#
# $HOME is artifacts and dependencies, not a workspace.
# apps and data seperation is lost entirely:
# - /usr/local for "local software" apps
# - $HOME for "personal files" data
#
# We merge "personal files" into "local software",
# and move the "idea of home" into a new directory.
# $HOME/dev is our new home.
#
# | directory      | path  | dependency     |
# | -------------- | ----- | -------------- |
# | /              |       | Linux          |
# | /usr           |       | Debian         |
# | /usr/local     | ~     | npm, pip, rust |
# | /usr/local/dev | ~/dev |                |

cd /

# take over
sudo chown -R $USER:$USER /usr/local/
find /usr/local/ -type d -empty -delete

# move
cp -r $HOME/. /usr/local/.
sudo sed -i "s|$HOME|/usr/local|" /etc/passwd
rm -fr $HOME/

# new home in $HOME
mkdir -p /usr/local/dev
