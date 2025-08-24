# fixes bash in VS Code Terminal
# Windows Terminal does not have this issue

# https://manpages.debian.org/trixie/bash/bash.1.en.html#INVOCATION
# `bash` without `--login` sources this file instead of `~/.profile`
# that's an "interactive" AND "non-login" shell invocation.

source ~/.profile
