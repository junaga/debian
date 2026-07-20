# https://manpages.debian.org/bash.en

test "$PS1" || return
echo "Hello, $USER!"

# fixes
################
set +h # lookup $PATH every time
shopt -s nullglob # globs match nothing
shopt -s checkwinsize # update $LINES and $COLUMNS every time
shopt -s histappend # dont overwrite, append ~/.bash_history
declare HISTFILESIZE="-1" # not 500, unlimited ~/.bash_history
declare HISTSIZE="-1" # not 500, unlimited bash history

# interface
################
declare BLUE="\[\e[1;34m\]"
declare RESET="\[\e[0m\]"

declare PS1="$BLUE\H\$PWD$RESET "
declare PS2="	"

bind "\C-H":backward-kill-word # CTRL+Backspace deletes a word
shopt -s autocd # cd directories automatically
shopt -s globstar # allow recursive globs "**"

# initialization
##########################
alias date="date +%Y-%m-%d"
alias datetime="env date +%Y-%m-%d-%H-%M-%S"
function man { echo "https://manpages.debian.org/$1.en"; }

alias ls="ls --color --group-directories-first"
alias rcp="rsync -azP --filter=\":- .gitignore\""
function rcode { code --remote ssh-remote+$1 $2; }
alias chat="codex resume --yolo"

export PAGER="less -FRX"
export EDITOR="micro"
