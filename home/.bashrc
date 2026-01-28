# fixes bash in VS Code Terminal
# - Windows Terminal does not have this issue

# https://manpages.debian.org/bash.en#INVOCATION
# bash without --login runs ~/.bashrc ignoring ~/.profile
# becomes an "interactive" and "non-login" shell invocation
# 1. how can a shell be interactive, with no user?
# 2. why is VS Code calling bash like that?

source ~/.profile
