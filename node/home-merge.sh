# ===== PROBLEM =====
# $HOME is not a workspace anymore; it's a mess:
#  - installations and dependencies
#  - artifacts, caches, and logs
#  - dotdirs and package managers
#  - XDG Config, XDG Cache, XDG Data
# The Unix app and data seperation, is lost:
#  1. /usr/local for installed apps
#  2. $HOME for saved data

# ===== SOLUTION =====
# 1. We merge $HOME into /usr/local
# 2. Our new workspace is $HOME/dev
# | directory      | path  | scope          |
# | -------------- | ----- | -------------- |
# | /usr/local/dev | ~/dev | user           |
# | /usr/local     | ~     | npm, pip, rust |
# | /usr           |       | Debian         |
# | /              |       | Linux          |

cd /

# claim and cleanup
sudo chown -R $USER:$USER /usr/local/
find /usr/local/ -type d -empty -delete

# move and merge
cp -ar $HOME/. /usr/local/.
sudo sed -i "s|$HOME|/usr/local|" /etc/passwd

# our new home in $HOME
mkdir -p /usr/local/dev
echo "exit the shell to reload"
