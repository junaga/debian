export DEBIAN_FRONTEND="noninteractive"
apt update

# translations and documentation
apt autoremove --purge --yes\
  debconf-i18n\
  manpages\
  man-db\
  info;
