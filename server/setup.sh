# autologin Linux terminals
sudo systemctl edit getty@.service --stdin <<-EOF
	[Service]
	ExecStart=
	ExecStart=-login -f $USER
EOF

# enable SSH forwarding
systemctl --user enable --now ssh-agent.socket

# generate an SSH key once
SSH_KEY="$HOME/.ssh/id_ed25519"
install -d -m 700 "$HOME/.ssh"
if [ ! -f "$SSH_KEY" ]; then
	ssh-keygen -q -N "" \
		-f "$SSH_KEY" \
		-C "$USER@$HOSTNAME"
fi

if [ ! -f "$SSH_KEY.pub" ]; then
	ssh-keygen -y -f "$SSH_KEY" > "$SSH_KEY.pub"
fi

echo
echo "SSH public key:"
echo
cat "$SSH_KEY.pub"
echo
