apt update
apt purge --yes \
  tasksel \
  tasksel-data \
  zutty \
  w3m \
  vim-tiny \
  vim-common \
  less \
  whiptail
  # logrotate \
  # logsave

apt autoremove --yes

#=== Translations and Documentation ===

update-locale LANG=C.UTF-8

apt purge --yes \
  debconf-i18n \
  man-db \
  info

rm -r /usr/share/locale/
rm -r /usr/share/dict/
rm -r /usr/share/man/
rm -r /usr/share/doc/
rm -r /usr/share/doc-base/
rm -r /usr/share/common-licenses/
rm -r /usr/share/bug/

#=== Empty Directories ===

rm -r /root/
rm -r /opt/
rm -r /srv/
rm -r /usr/src/
rm -r /usr/games/

# only in vm
# rm -r /boot/
# rm -r /media/
# rm -r /lost+found/

rm -r /usr/local/src/
rm -r /usr/local/games/
rm -r /usr/local/man
rm -r /usr/local/include/
rm -r /usr/local/share/
rm -r /usr/local/sbin/
rm -r /usr/local/etc/

#=== Display Names for UIDs ===

# legacy unix
deluser daemon
deluser bin
deluser sys
deluser sync
deluser games
deluser man
deluser lp

# outdated network protocol servers
deluser mail
deluser news
deluser uucp
deluser proxy

# applications
deluser www-data
deluser backup
deluser list
deluser irc
