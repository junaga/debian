# Modern Linux $HOME is fucked beyond repair,
# there's a billion things, some include:
#   - dotdirs
#   - non-sudo package managers
#   - user installations
#   - XDG
#     - Config
#     - Cache
#     - Data
#
# The seperation between apps and data lost all clarity:
#   - "local software" /usr/local
#   - "personal files" $HOME
#
# We merge "personal files" and "local software",
# then move the idea of "a home" into a new directory.
#
# The new system looks something like this
# | path           | dependency         |
# | -------------- | ------------------ |
# | /              | Linux              |
# | /usr           | Debian             |
# | /usr/local     | npm, pip, go, rust |
# | /usr/local/dev |                    |

cd /

# take over
sudo chown -R $USER:$USER /usr/local/
find /usr/local/ -type d -empty -delete

# move
cp -r $HOME/. /usr/local/.
rm -fr $HOME/

# update config
sudo sed -i "s|$HOME|/usr/local|" /etc/passwd

# new home in $HOME
mkdir -p /usr/local/dev
