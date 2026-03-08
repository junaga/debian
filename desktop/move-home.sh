USER="$1"

# delete empty directories
find /usr/local/ -type d -empty -delete

# copy home directory
chown -R $USER:$USER /usr/local/
cp -r /home/$USER/. /usr/local/.

# update system config
sed -i "s|/home/$USER|/usr/local|" /etc/passwd
sed -i "s|/root|/tmp|" /etc/passwd

# delete home directories
rm -fr /home/
rm -fr /root/
