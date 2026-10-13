# https://manpages.debian.org/bash.en

# no human == exit
test "$PS1" || return

# fix bash quirks
set +h # lookup $PATH every time
shopt -s checkwinsize # update $LINES and $COLUMNS every time

# fix logging
shopt -s histappend # dont overwrite, append ~/.bash_history
declare HISTFILESIZE="-1" # not 500, unlimited ~/.bash_history
declare HISTSIZE="-1" # not 500, unlimited bash history

# command line
declare BLUE="\[\e[1;34m\]"
declare RESET="\[\e[0m\]"
declare PS1="$BLUE\H\$PWD$RESET "

# directories
shopt -s autocd # cd directories by running
shopt -s nullglob # globs match nothing
shopt -s globstar # allow recursive globs "**"

# environment
test -r "$HOME/.env" && eval "$(direnv dotenv bash "$HOME/.env"; export)"
export REPO="${REPO-/usr/src/local}" WORK="${WORK-$HOME}"
cd "$WORK" # cd WORK

# aliases
alias ls="ls --color=auto --group-directories-first"
alias rcp="rsync -azP --filter=\":- .gitignore\""
alias date="date +%Y-%m-%d"
alias datetime="command date +%Y-%m-%d-%H-%M-%S"
alias deploy="wrangler pages deploy"
function desktop { exec run0 --pipe -u "${1-1000}" "${DESKTOP-hyprland}"; }
function man { echo "https://manpages.debian.org/$1.en"; }
function rcode { code --remote "ssh-remote+$1" "$2"; }
