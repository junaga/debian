apt update
apt autoremove --yes

apt purge --yes \
  vim-tiny \
  vim-common \
  less \
  tasksel \
  tasksel-data \
  whiptail

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
