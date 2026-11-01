# Initialize this Unix account's preferences, git, and ssh.
# Run after base/install.sh; EMAIL defaults to $USER@$HOSTNAME.

set -eu
USER=$(whoami)
EMAIL=${EMAIL:-$USER@$(hostname)}
cat "$(dirname "$0")/.env" >> "$HOME/.env"
echo "EMAIL=$EMAIL" >> "$HOME/.env"

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
