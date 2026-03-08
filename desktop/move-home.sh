USER="$1"

# delete empty directories
find /usr/local/ -type d -empty -delete

# copy home directory
chown -R $USER:$USER /usr/local/
cp -r $HOME/. /usr/local/.

# update system config
sed -i "s|$HOME|/usr/local|" /etc/passwd

# delete old home
rm -fr $HOME/
