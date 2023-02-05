echo "Welcome $USER"
trap 'echo "Goodbye $USER, now on lvl $((SHLVL-1))"' EXIT

##### Fix the shell #####
# don't cache binary locations. search $PATH on every command entered
set +h

# globbing exists, it should at least work
shopt -s nullglob globstar dotglob
GLOBIGNORE=.:..

# tab tab tab
# requires the apt:bash-completion package
source /usr/share/bash-completion/bash_completion

# think of the noobs
# requires the apt:command-not-found package
function command_not_found_handle { /usr/bin/command-not-found "$1"; }

##### History not mystery #####
# https://manpages.debian.org/bullseye/bash/bash.1.en.html#HISTORY
HISTIGNORE="export *" # but keep secrets secret
HISTSIZE=-1 # keep history of all commands (not just 500) entered
shopt -s histappend # append to the history file, don't overwrite it
PROMPT_COMMAND="history -a" # write memory to history file on every command entered

##### Commands #####
# send ANSI color codes to the terminal
# # show me someone with a b&w CRT monitor
# # nvm: https://www.reddit.com/r/crtgaming/comments/u2nbu4/may_i_present_you_this_tiny_bw_crt_its_only_5/
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
