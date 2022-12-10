echo "Welcome $USER, lvl $SHLVL"
trap 'echo "Goodbye $USER, lvl $((SHLVL-1))"' EXIT

##### Fix the Shell #####
# disable command hashmap, recrawl $PATH on every prompt
set +h

# sensible ~/.bash_history settings
HISTIGNORE="export *"
shopt -s histappend
PROMPT_COMMAND="history -a && history -n"
HISTSIZE=-1
HISTFILESIZE=-1

# shellcheck disable=SC1091 
source /usr/share/bash-completion/bash_completion

alias ls='ls --color=auto'
alias grep='grep --color=auto'

##### We work with #####
export PAGER="less"
export EDITOR="code --wait" # VS Code FTW
# unset WINDOW_MANAGER
# export BROWSER="chrome" # everything is chrome in the future

# only required when App setting "terminal.integrated.shellIntegration.enabled" is false.
# shellcheck disable=SC1090
source "$(code --locate-shell-integration-path bash)"
