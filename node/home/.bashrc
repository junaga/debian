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
declare WHITE="\[\e[1;37m\]"
declare BLUE="\[\e[1;34m\]"
declare RESET="\[\e[0m\]"

# "host:directory "
declare PS1="$WHITE\H:$BLUE\$PWD$RESET "
declare PS2="	"

# shell initialization
##########################
function man { echo "https://manpages.debian.org/$1.en"; }
alias ls="ls --color --group-directories-first"
alias date="date +%Y-%m-%d-%H-%M-%S"
alias rcp="rsync -azP --filter=\":- .gitignore\""
function rcode { code --remote ssh-remote+$1 $2; }
alias chat="codex --dangerously-bypass-approvals-and-sandbox"

function ssh_bridge { eval "$(ssh-agent -s)"; ssh-add ~/.ssh/id_ed25519; }
