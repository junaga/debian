set -e

# Not for WSL or systemd-less systems.
USER=$(whoami)
EMAIL=${EMAIL:-$USER@$(hostname)}

# Autologin Linux virtual terminals.
sudo systemctl edit --stdin getty@.service <<-ESC
	[Service]
	ExecStart=
	ExecStart=-login -f $USER
ESC

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
