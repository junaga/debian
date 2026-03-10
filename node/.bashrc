# https://manpages.debian.org/bash.en

test "$PS1" || return
echo "Welcome $USER"
trap "echo \"level $((SHLVL - 1)) entered\"" EXIT

# bash fixed
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

# bash CLI
################
function _container_test { test -f "/run/.containerenv" || test -f "/.dockerenv"; }
function _container_name { _container_test && cat /etc/hostname; }
function _branch_name { git branch --show-current 2>/dev/null; }
function _container { name=$(_container_name); echo -n ${name:+$name|}; }
function _branch { name=$(_branch_name); echo -n ${name:+|$name}; }

declare _reset="\[\e[0m\]"
declare _blue="\[\e[1;34m\]"
declare _green="\[\e[1;32m\]"

# "time container directory branch"
#           "HH:MM     [container|]        directory[|branch]  $ "
declare PS1="\A $_green\$(_container)$_blue\w$_reset\$(_branch)$ "
declare PS2="	"

# shell initialization
##########################
function man { echo "https://manpages.debian.org/$1.en"; }
function ls { env ls --color="auto" --group-directories-first "$@"; }
function time { date +%Y-%m-%d-%H-%M-%S; }
function micro { env micro --config-dir /tmp "$@"; }
function ssh { TERM=xterm-256color ssh -o StrictHostKeyChecking=no "$@"; }
function claw { openclaw "$@"; }

# environment variables
# set -a
# . ~/.env
# set +a

# # fix file permissions and wsl.exe artifacts
# colonize() { sudo chown -R $USER:$USER "$1"; }
# fuckdirs() { find "$1" -type d -exec chmod 755 {} +; }
# fuckfiles() { find "$1" -type f -exec chmod 644 {} +; }
# fuckwindows() { find "$1" -type f -name "*Zone.Identifier" -delete; }
