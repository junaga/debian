# https://manpages.debian.org/bash.en

echo "Welcome $USER"
trap "echo \"Goodbye $USER leaving level $SHLVL\"" EXIT

# bash fixed
################
shopt -s histappend # dont overwrite, append ~/.bash_history
declare HISTFILESIZE="-1" # not 500, unlimited ~/.bash_history
declare HISTSIZE="-1" # not 500, unlimited bash history
shopt -s checkwinsize # update $LINES and $COLUMNS every time
set +h # lookup $PATH every time

shopt -s nullglob # fix globing
shopt -s dotglob # allow globs on dotfiles
shopt -s globstar # allow recursive glob "**"
shopt -s autocd # cd directories automatically
bind "\C-H":backward-kill-word # CTRL+Backspace deletes a word

# bash CLI (shell prompt)
# shows: container, directory, branch. not username, not hostname
################
declare bold_blue="\[\e[1;34m\]"
declare bold_green="\[\e[1;32m\]"
declare reset="\[\e[0m\]"
__container_name_ps1() { test -f "/.dockerenv" && cat /etc/hostname; }
# "HH:MM [CONTAINER]DIRECTORY[|BRANCH]$ "
declare PS1="\A $bold_green\$(__container_name_ps1)$bold_blue\w$reset\$(__git_ps1 '|%s')$ "
declare PS2="	"
unset bold_blue bold_green reset

# bash functions and variables
##########################
source ~/.aliases
set -a # shell variables == environment variables
source ~/.env
