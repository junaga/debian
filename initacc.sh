# Initialize this Unix account's git and ssh.
# Run after instpkg.sh; EMAIL defaults to $USER@$HOSTNAME.

set -eu
USER=$(whoami)
EMAIL=${EMAIL:-$USER@$(hostname)}

# Enable Linux virtual terminal autologin.
if test -c /dev/tty0; then
	sudo systemctl edit --stdin getty@.service <<-ESC
		[Service]
		ExecStart=
		ExecStart=-login -f $USER
	ESC
fi

# Containers need users and groups on the shared kernel.
grep -q ^$USER: /etc/subuid || sudo usermod --add-subuids 100000-165535 $USER
grep -q ^$USER: /etc/subgid || sudo usermod --add-subgids 100000-165535 $USER

# Create an SSH public/private key pair if missing.
# Use EMAIL as the public key comment to simplify administration.
mkdir -p ~/.ssh
test -f ~/.ssh/id_ed25519 || ssh-keygen -N '' \
	-f ~/.ssh/id_ed25519 \
	-C $EMAIL

# Git records your name and email in commits.
# GitHub uses the email to associate commits with your account.
git config --global user.name $USER
git config --global user.email $EMAIL
