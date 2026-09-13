set -e

USER=$(whoami)
EMAIL=${EMAIL:-$USER@$(hostname)}

# Local login
# ==============================================================================

# Autologin Linux virtual terminals.
sudo systemctl edit --stdin getty@.service <<-ESC
	[Service]
	ExecStart=
	ExecStart=-login -f $USER
ESC

# User containers
# ==============================================================================

# Containers need users and groups on the shared kernel.
grep -q ^$USER: /etc/subuid || sudo usermod --add-subuids 100000-165535 $USER
grep -q ^$USER: /etc/subgid || sudo usermod --add-subgids 100000-165535 $USER

# SSH identity
# ==============================================================================

# Create an SSH identity if missing.
mkdir -p ~/.ssh
test -f ~/.ssh/id_ed25519 || ssh-keygen -N '' \
	-f ~/.ssh/id_ed25519 \
	-C $EMAIL

# Git author
# ==============================================================================

git config --global user.name $USER
git config --global user.email $EMAIL
