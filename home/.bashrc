# fix: bash in VS Code Terminal
# - Windows Terminal does not have this issue
# - issue: bash is invoked "interactive" and "non-login"
#   1: how can a shell be interactive, without a user (login)?
#   2: why is VS Code calling bash like that?
# - docs: https://manpages.debian.org/bash.en#INVOCATION

source ~/.profile
