# https://manpages.debian.org/bash.en

test "$PS1" || return
echo "Hello, $USER!"

umask 0002

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
function branch {
	BRANCH=$(git branch --show-current 2>/dev/null)
	test $BRANCH && echo "|$BRANCH"
}

declare BLACK="\[\e[1;30m\]"
declare RED="\[\e[1;31m\]"
declare GREEN="\[\e[1;32m\]"
declare YELLOW="\[\e[1;33m\]"
declare BLUE="\[\e[1;34m\]"
declare MAGENTA="\[\e[1;35m\]"
declare CYAN="\[\e[1;36m\]"
declare WHITE="\[\e[1;37m\]"
declare RESET="\[\e[0m\]"

# "host:directory|branch"
declare PS1="$WHITE\H:$BLUE\$PWD$CYAN\$(branch)$RESET "
declare PS2="	"

# shell initialization
##########################
function ls { env ls --color="auto" --group-directories-first "$@"; }
function date { env date +%Y-%m-%d-%H-%M-%S; }
function man { echo "https://manpages.debian.org/$1.en"; }
function micro { env micro --config-dir /tmp -softwrap true -wordwrap true "$@"; }
function rcp { rsync -azP --filter=":- .gitignore" "$@"; }
function rcode { code --remote ssh-remote+$1 $2; }
function chat { codex --dangerously-bypass-approvals-and-sandbox "$@"; }

function ssh_bridge { eval "$(ssh-agent -s)"; ssh-add ~/.ssh/id_ed25519; }
