# autologin Linux terminals
sudo systemctl edit getty@.service --stdin <<-EOF
	[Service]
	ExecStart=
	ExecStart=-login -f $USER
EOF

# input $EMAIL
echo "The email labels your SSH public key for simpler management."
echo "Your GitHub email links pushed Git commits to your profile for attribution."
read -e -i "$USER@$HOSTNAME" -p "Email: " EMAIL

# generate SSH key
mkdir -p ~/.ssh
ssh-keygen -q -N "" \
	-f ~/.ssh/id_ed25519 \
	-C "$EMAIL"

# enable SSH forwarding
systemctl --user enable --now ssh-agent.socket

# set author for git commits
git config --global user.name "$USER"
git config --global user.email "$EMAIL"

# output $SSH_PUBLIC_KEY
echo ============================
echo "Copy this SSH public key to remote systems for authentication:"
cat ~/.ssh/id_ed25519.pub
echo ============================
