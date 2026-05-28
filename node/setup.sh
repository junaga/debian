# autologin Linux terminals
sudo systemctl edit getty@.service --stdin <<-EOF
	[Service]
	ExecStart=
	ExecStart=-login -f $USER
EOF

# generate SSH key
ssh-keygen -N "" -C $USER@$HOSTNAME
echo
echo "SSH public key:"
echo
cat ~/.ssh/id_ed25519.pub
echo

# enable SSH forwarding
systemctl --user enable --now ssh-agent.socket
