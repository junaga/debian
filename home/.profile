# https://manpages.debian.org/bash.en

echo "Welcome $USER"
trap "echo \"Goodbye $USER leaving level $SHLVL\"" EXIT

# fix bash
################
declare HISTSIZE="-1" # unlimited bash history size, not 500
declare HISTFILESIZE="-1" # unlimited ~/.bash_history size, not 500
shopt -s histappend # append to ~/.bash_history instead of overwriting it
shopt -s checkwinsize # update variables $LINES and $COLUMNS after each command
set +h # disable caching $PATH lookups (new installed binaries work without shell restart)

shopt -s nullglob # globbing matches nothing (dont preserve "*.txt" arg if no txt files exist)
shopt -s dotglob # globbing matches dotfiles ("*cache" matches .cache)
shopt -s globstar # enable ** for recursive globbing
shopt -s autocd # cd directories automatically
# set -a # all shell variables become environment variables
bind "\C-H":backward-kill-word # CTRL+Backspace deletes a word

source /usr/share/bash-completion/bash_completion # bash-completion package
function command_not_found_handle { command-not-found "$1"; } # command-not-found package

# bash prompt
################
declare bold_blue="\[\e[1;34m\]"
declare bold_green="\[\e[1;32m\]"
declare reset="\[\e[0m\]"
__container_name_ps1() { test -f "/.dockerenv" && cat /etc/hostname; }

# show path and optionally git branch, don't show username and hostname
# "HH:MM [CONTAINER_NAME]PWD[|GIT_BRANCH]$ "
declare PS1="\A $bold_green\$(__container_name_ps1)$bold_blue\w$reset\$(__git_ps1 '|%s')$ "
declare PS2="	"

unset bold_blue bold_green reset

# functions and variables
##########################
source ~/.aliases
set -a
source ~/.env
