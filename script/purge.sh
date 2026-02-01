apt update
apt autoremove --purge --yes \
  w3m \
  vim-tiny \
  vim-common \
  nano \
  less \
  whiptail \
  tasksel \
  tasksel-data

find ./ -type d -empty -delete

rm -r /lost+found/
rm -r /usr/games/
rm -r /usr/src/
rm -r /opt/
rm -r /srv/

#=== Translations and Documentation ===

apt autoremove --purge --yes \
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
unlink /usr/local/man

#=== Artifacts and Caches ===

rm -r .cache/
rm -fr .npm/_cacache/
rm -fr .vscode-server/
rm -r .dotnet/
rm -r .w3m/
rm .sudo_as_admin_successful
rm .wget-hsts
rm .verapdf/
rm .java/fonts/

# rm .bash_history
# rm .python_history
# rm .node_repl_history
