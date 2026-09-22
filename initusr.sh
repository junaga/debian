# Initialize this user's Git, SSH, container IDs, and console autologin.
# Run after instpkg.sh with EMAIL set; uses sudo for system settings.

set -eu
USER=$(whoami)

# GitHub finds your commits by email, not Git user name.
# SSH uses EMAIL only as a label for the public key.
EMAIL=${EMAIL:?Set EMAIL for Git and SSH}

# Autologin Linux virtual terminals.
if ! grep -qi microsoft /proc/sys/kernel/osrelease && test -d /run/systemd/system; then
	sudo systemctl edit --stdin getty@.service <<-ESC
		[Service]
		ExecStart=
		ExecStart=-login -f $USER
	ESC
fi

# Containers need users and groups on the shared kernel.
grep -q ^$USER: /etc/subuid || sudo usermod --add-subuids 100000-165535 $USER
grep -q ^$USER: /etc/subgid || sudo usermod --add-subgids 100000-165535 $USER

# Create an SSH identity if missing.
mkdir -p ~/.ssh
test -f ~/.ssh/id_ed25519 || ssh-keygen -N '' \
	-f ~/.ssh/id_ed25519 \
	-C $EMAIL

git config --global user.name $USER
git config --global user.email $EMAIL
