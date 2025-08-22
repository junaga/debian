apt update
apt purge --yes \
  tasksel \
  tasksel-data \
  zutty \
  w3m \
  vim-tiny \
  vim-common \
  nano \
  less \
  whiptail
  # logrotate \
  # logsave

apt autoremove --yes

#=== Cache and Artifacts ===

rm -r ~/.cache/
rm -fr ~/.npm/_cacache/
rm -fr ~/.vscode-server/
rm -r ~/.dotnet/
rm -r ~/.w3m/

rm ~/.sudo_as_admin_successful
rm ~/.wget-hsts

rm ~/.verapdf/
rm ~/.java/fonts/

# rm ~/.bash_history
# rm ~/.python_history
# rm ~/.node_repl_history

#=== Translations and Documentation ===

update-locale LANG=C.UTF-8
timedatectl set-timezone UTC

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

find ~/ -type d -empty -delete

rm -r /root/
rm -r /srv/
rm -r /opt/
rm -r /var/opt/
rm -r /var/local/
rm -r /usr/src/
rm -r /usr/games/

# only in vm
# rm -r /boot/ /media/ /lost+found/

rm -r /usr/local/sbin/
rm -r /usr/local/etc/
rm -r /usr/local/include/
rm -r /usr/local/share/
rm -r /usr/local/man
rm -r /usr/local/games/

#=== Compartmentalization with users ===

deluser backup
deluser list
deluser games

# obsolete servers
deluser news
deluser uucp
deluser irc
deluser proxy

# legacy unix (became either root or systemd)
deluser man
deluser bin
deluser sys
deluser daemon
deluser sync
