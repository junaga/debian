# When local administration and recovery take priority over preventing unauthorized
# root access, enable autologin on trusted physical or hypervisor consoles.
# SSH, serial consoles and display managers retain their existing authentication.
test -c /dev/tty0 || exit 0
systemctl edit getty@.service --stdin <<-EOF
	[Service]
	ExecStart=
	ExecStart=-login -f root
EOF
