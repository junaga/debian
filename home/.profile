source ~/junaga.sh

# deb:bash-completion
source /usr/share/bash-completion/bash_completion
# deb:command-not-found
function command_not_found_handle { /usr/bin/command-not-found "$1"; }

##### Fix the shell #####
# `$ export` all
set -a
# dont cache `bin/`s.
set +h
# globbing
shopt -s nullglob globstar dotglob
GLOBIGNORE=.:..

##### History not mystery #####
# https://manpages.debian.org/bullseye/bash/bash.1.en.html#HISTORY
HISTIGNORE="export *=*" # but keep secrets secret
HISTSIZE=-1 # keep history of all commands entered, not just 500
PROMPT_COMMAND="history -a" # write memory to file on every command entered
shopt -s histappend # append to the file, don't overwrite it
