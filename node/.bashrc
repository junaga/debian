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
declare BLACK="\[\e[1;30m\]"
declare RED="\[\e[1;31m\]"
declare GREEN="\[\e[1;32m\]"
declare YELLOW="\[\e[1;33m\]"
declare BLUE="\[\e[1;34m\]"
declare MAGENTA="\[\e[1;35m\]"
declare CYAN="\[\e[1;36m\]"
declare WHITE="\[\e[1;37m\]"
declare RESET="\[\e[0m\]"

function host {
	DEFAULT="home"
	test $HOSTNAME != $DEFAULT && echo "$HOSTNAME"
}

function branch {
	BRANCH=$(git branch --show-current 2>/dev/null)
	test $BRANCH && echo "|$BRANCH"
}

# "time host directory branch"
declare PS1="\A $GREEN\$(host)$BLUE\w$WHITE\$(branch)$RESET\$ "
declare PS2="	"

# shell initialization
##########################
function ls { env ls --color="auto" --group-directories-first "$@"; }
function date { env date +%Y-%m-%d-%H-%M-%S; }
function micro { env micro --config-dir /tmp -softwrap true -wordwrap true "$@"; }
function man { echo "https://manpages.debian.org/$1.en"; }
function chat { openclaw tui --session $PWD; }

# environment variables
test -f ~/.env && {	
	set -a
	. ~/.env
	set +a
}
