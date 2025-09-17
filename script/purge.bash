rm -r /lost+found/

apt update
apt purge --yes \
  w3m \
  vim-tiny \
  vim-common \
  nano \
  less \
  whiptail \
  tasksel \
  tasksel-data

apt autoremove --yes

#=== Empty Directories ===

find ~/ -type d -empty -delete
rm -r /usr/games/
rm -r /usr/src/
rm -r /opt/
rm -r /srv/

#=== Home Artifacts and Caches ===

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

#=== Compartmentalization with users ===

deluser list
deluser games
deluser sync
deluser backup

# deprecated non-root users
deluser man
deluser bin
deluser sys

#=== Translations and Documentation ===

apt purge --yes \
  debconf-i18n \
  man-db \
  info
apt autoremove --yes

update-locale LANG=C.UTF-8
rm -r /usr/share/locale/
rm -r /usr/share/dict/
rm -r /usr/share/man/
rm -r /usr/share/doc/
rm -r /usr/share/doc-base/
rm -r /usr/share/common-licenses/
rm -r /usr/share/bug/

unlink /usr/local/man
