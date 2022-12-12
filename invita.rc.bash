echo "Welcome $USER, lvl $SHLVL"
trap 'echo "Goodbye $USER, lvl $((SHLVL-1))"' EXIT

##### Fix the Shell #####
# disable command hashmap, recrawl $PATH on every prompt
set +h

# sensible ~/.bash_history settings
HISTIGNORE="export *"
shopt -s histappend
PROMPT_COMMAND="history -a; history -n"
HISTSIZE=-1
HISTFILESIZE=-1

# shellcheck disable=SC1091
source /usr/share/bash-completion/bash_completion

alias ls='ls --color=auto -h'
alias grep='grep --color=auto'

##### History not Mystery #####
# https://manpages.debian.org/bullseye/bash/bash.1.en.html#HISTORY
HISTSIZE=-1 # save all commands, not just the last 500
HISTIGNORE="export *" # keep secrets secret

PROMPT_COMMAND="history -a" # write memory (history) to file on every command entered

log="$HOME/logs/bash-$(date --utc +%Y-%m-%d-%H-%M-%S).log"
mkdir -p "$HOME/logs/" && touch "$log"
HISTFILE="$log"
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
