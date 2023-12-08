# https://manpages.debian.org/bookworm/bash/bash.1.en.html

source ~/junaga.sh

# https://packages.debian.org/stable/command-not-found
function command_not_found_handle { /usr/bin/command-not-found "$1"; }
# https://packages.debian.org/stable/bash-completion
source /usr/share/bash-completion/bash_completion

## I am speed
# set -a # `$ export` variables # TODO: vscode bug
shopt -s autocd # `$ cd` directories
bind "\C-H":backward-kill-word # CTRL+Backspace removes words

## whenami, whereami, "HH:MM PWD[|GIT_BRANCH]$ "
bold_blue="\[\e[1;34m\]"; reset="\[\e[0m\]"
PS1="\A $bold_blue\w$reset\$(__git_ps1 '|%s')\$ "
PS2="	" # a single tab, U+0009
PS4="$ " # printed in `-x` mode
unset bold_blue reset

## History, not Mystery
HISTIGNORE="export *" # and Secrets
HISTCONTROL="erasedups"
HISTSIZE="-1" # not 500
HISTFILE="" # save manually
touch $HOME/log
PROMPT_COMMAND="history -a $HOME/log; history -r $HOME/log"

## Pro gamer, globbing language
shopt -s nullglob # fix: expand no match
shopt -s dotglob # match `.`files
shopt -s globstar # enable `**`

set +h # disable `$PATH` cache
