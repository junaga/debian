echo "Welcome $USER, shell log:"
trap 'echo "Goodbye $USER, now lvl $((SHLVL-1))"' EXIT

##### Fix the Shell #####
# disable memory hashmap, recrawl $PATH on every command entered
set +h
# keep memory of all commands (else 500) entered
HISTSIZE=-1

# show me someone with a CRT monitor
alias ls='ls --color=auto -h'
alias grep='grep --color=auto'

# tab tab tab
# shellcheck disable=SC1091
source /usr/share/bash-completion/bash_completion

##### History not Mystery #####
# https://manpages.debian.org/bullseye/bash/bash.1.en.html#HISTORY

HISTIGNORE="export *" # but keep secrets secret
PROMPT_COMMAND="history -a" # write memory to file on every command entered
log="$HOME/logs/bash-$(date --utc +%Y-%m-%d-%H-%M-%S).log"
HISTFILE="$log"

touch -p "$log" && echo "  $log"
unset log

##### We work with #####
export PAGER="less"
export EDITOR="code --wait" # VS Code FTW
# unset WINDOW_MANAGER
# export BROWSER="chrome" # everything is chrome in the future

prev=$PROMPT_COMMAND
# only required when App setting "terminal.integrated.shellIntegration.enabled" is false.
# shellcheck disable=SC1090
source "$(code --locate-shell-integration-path bash)"
PROMPT_COMMAND="$prev; $PROMPT_COMMAND"
unset prev
