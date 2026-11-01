# ====================================================
# Fix bash shell quirks and short sighted design
# ====================================================
# https://manpages.debian.org/bash.en

test "$PS1" || return # no human == exit

set +h # lookup $PATH every time
shopt -s checkwinsize # update $LINES and $COLUMNS every time

shopt -s histappend # dont override, append ~/.bash_history
declare HISTFILESIZE="-1" # not 500, unlimited ~/.bash_history
declare HISTSIZE="-1" # not 500, unlimited bash history

# ====================================================
# Fast command line, inspired by URL and .gitignore
# ====================================================

declare BLUE="\[\e[1;34m\]"
declare RESET="\[\e[0m\]"
declare PS1="$BLUE\H\$PWD$RESET "

shopt -s autocd # cd directories by running
shopt -s nullglob # globs match nothing
shopt -s globstar # allow recursive globs "**"

# ====================================================
# env variables, aliases, and functions
# ====================================================

set -a; . ~/.env; set +a
export DATE=$(date --iso)

alias ls="ls --color=auto --group-directories-first"
alias rcp="rsync -azP"
