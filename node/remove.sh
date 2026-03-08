export DEBIAN_FRONTEND="noninteractive"
apt update

# pager, editors, browser
apt autoremove --purge --yes\
  less\
  nano\
  vim-tiny\
  vim-common\
  w3m;

# translations and documentation
apt autoremove --purge --yes\
  debconf-i18n\
  manpages\
  man-db\
  info;
