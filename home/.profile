# github:junaga/debian
source ~/gh/debian/home/junaga.sh

#### Fix the Shell ####
# https://manpages.debian.org/bookworm/bash/bash.1.en.html

# deb:bash-completion
source /usr/share/bash-completion/bash_completion

# deb:command-not-found
function command_not_found_handle { /usr/bin/command-not-found "$1"; }

# Pro Gamer - Globbing
shopt -s dotglob # match `.`files
shopt -s globstar # enable `**`
shopt -s nullglob # fix: no match

# History, Memory and File, Sync
HISTSIZE="-1" # not 500
PROMPT_COMMAND="history -n && history -a"
HISTCONTROL="erasedups" # ignorespace:erasedups

set -a # `$ export` all variables
shopt -s autocd # `$ cd` all directories
set +h # dont cache `$PATH` commands
