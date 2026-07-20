# autologin Linux terminals
sudo systemctl edit getty@.service --stdin <<-EOF
	[Service]
	ExecStart=
	ExecStart=-login -f $USER
EOF

# enable SSH forwarding
systemctl --user enable --now ssh-agent.socket

# generate SSH key
ssh-keygen -q -N "" \
	-f ~/.ssh/id_ed25519 \
	-C $USER@$HOSTNAME

echo
echo "SSH public key:"
echo
cat ~/.ssh/id_ed25519.pub
echo
