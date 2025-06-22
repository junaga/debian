# https://manpages.debian.org/bookworm/bash/bash.1.en.html

source ~/init.sh
source ~/junaga.sh

echo "Welcome $USER"
trap "echo \"Goodbye $USER leaving level $SHLVL\"" EXIT

# shell prompt
################
declare bold_blue="\[\e[1;34m\]"
declare bold_green="\[\e[1;32m\]"
declare reset="\[\e[0m\]"
__container_name_ps1() { test -f "/.dockerenv" && cat /etc/hostname; }

# show the full path and optionally git branch, don't show the username
# "HH:MM [CONTAINER_NAME]PWD[|GIT_BRANCH]$ "
declare PS1="\A $bold_green\$(__container_name_ps1)$bold_blue\$PWD$reset\$(__git_ps1 '|%s') "
declare PS2="	"

unset bold_blue bold_green reset

# settings
################
function command_not_found_handle { command-not-found "$1"; } # command-not-found package
source /usr/share/bash-completion/bash_completion # bash-completion package

shopt -s autocd # cd directories automatically
bind "\C-H":backward-kill-word # CTRL+Backspace deletes a word
# set -a # all shell variables are environment variables

shopt -s nullglob # globbing matches nothing instead of itself
shopt -s dotglob # globbing matches dotfiles
shopt -s globstar # enable ** for recursive globbing

# fix bash
################
shopt -s histappend # append to ~/.bash_history instead of overwriting it
declare HISTSIZE="-1" # unlimited bash history size, not 500
declare HISTFILESIZE="-1" # unlimited ~/.bash_history size, not 500

shopt -s checkwinsize # update $LINES and $COLUMNS after each command
set +h # disable caching binary locations from $PATH search results
