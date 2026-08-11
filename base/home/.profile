# ~/.profile: root's login-shell entry point.

if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
fi

# /usr/local is the administrator workspace on this installation.
cd /usr/local
