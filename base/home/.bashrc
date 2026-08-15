# https://manpages.debian.org/bash.en

# exit when bash has no human
test "$PS1" || return

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
eval "$(direnv hook bash)" # load .env automatically
shopt -s autocd # cd directories automatically
shopt -s globstar # allow recursive globs "**"

declare BLUE="\[\e[1;34m\]"
declare RESET="\[\e[0m\]"
declare PS1="$BLUE\H\$PWD$RESET "

export LANG="C.UTF-8"
export PAGER="/bin/less"
# export SHELL="/bin/bash"
# export BROWSER="google-chrome-stable"
export EDITOR="micro"

# tools
##########################
alias ls="ls --color=auto --group-directories-first"
alias rcp="rsync -azP --filter=\":- .gitignore\""
alias date="date +%Y-%m-%d"
alias datetime="command date +%Y-%m-%d-%H-%M-%S"
function man { echo "https://manpages.debian.org/$1.en"; }

function rcode { code --remote "ssh-remote+$1" "$2"; }
alias chat="codex resume --yolo"

# cd /usr/local
