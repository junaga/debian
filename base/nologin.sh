# When local administration and recovery take priority over preventing unauthorized
# root access, enable autologin on trusted physical or hypervisor consoles.
# SSH, serial consoles and display managers retain their existing authentication.
# Register root as a greeter so the desktop user can take over the same seat.
test -c /dev/tty0 || exit 0
systemctl edit getty@.service --stdin <<-EOF
	[Service]
	Environment="XDG_SESSION_CLASS=greeter"
	ExecStart=
	ExecStart=-login -f root
EOF
