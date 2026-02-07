echo "Welcome $USER"
trap "echo \"Goodbye $USER leaving level $SHLVL\"" EXIT

# bash fixed
# https://manpages.debian.org/bash.en
################
shopt -s histappend # dont overwrite, append ~/.bash_history
declare HISTFILESIZE="-1" # not 500, unlimited ~/.bash_history
declare HISTSIZE="-1" # not 500, unlimited bash history
shopt -s checkwinsize # update $LINES and $COLUMNS every time
set +h # lookup $PATH every time

shopt -s nullglob # globs match nothing
shopt -s dotglob # globs match dotfiles
shopt -s globstar # allow recursive globs "**"

shopt -s autocd # cd directories automatically
bind "\C-H":backward-kill-word # CTRL+Backspace deletes a word

# bash CLI (shell prompt)
# "time container directory branch"
################
function _container_test { test -f "/run/.containerenv" || test -f "/.dockerenv"; }
function _container_name { _container_test && cat /etc/hostname; }
function _branch_name { git branch --show-current 2>/dev/null; }
function _container { name=$(_container_name); echo -n ${name:+$name|}; }
function _branch { name=$(_branch_name); echo -n ${name:+|$name}; }

declare _reset="\[\e[0m\]"
declare _blue="\[\e[1;34m\]"
declare _green="\[\e[1;32m\]"

#           "HH:MM     [container|]        directory[|branch]  $ "
declare PS1="\A $_green\$(_container)$_blue\w$_reset\$(_branch)$ "
declare PS2="	"

# bash functions and variables
##########################
source ~/.aliases
set -a # shell variables == environment variables
source ~/.env
