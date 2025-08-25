# fix: bash in VS Code Terminal
# - Windows Terminal does not have this issue

# bash without --login runs ~/.bashrc, ignoring ~/.profile
# that's an "interactive" and "non-login" shell invocation
# https://manpages.debian.org/bash.en#INVOCATION
# 1. how can a shell be interactive, but without a user ?
# 2. and why is VS Code calling bash like that?

source ~/.profile
