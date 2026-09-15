# Configure the current Debian user.
# Environments: WSL, VPS, PC
set -e

# Linux virtual-terminal autologin is not available on WSL or systemd-less systems.
USER=$(whoami)
EMAIL=${EMAIL:-$USER@$(hostname)}

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
