echo "Welcome $USER"
trap 'echo "Goodbye $USER, now on lvl $((SHLVL-1))"' EXIT

# shell variables (KEY=VALUE) are environment variables (export KEY=VALUE)
set -a

##### Fix the shell #####
# don't cache binary locations. search $PATH on every command entered
set +h

# fix globbing
shopt -s nullglob globstar dotglob
GLOBIGNORE=.:..

# tab tab tab
# requires the debian:bash-completion package
source /usr/share/bash-completion/bash_completion

# think of the noobs
# requires the debian:command-not-found package
function command_not_found_handle { /usr/bin/command-not-found "$1"; }

##### History not mystery #####
# https://manpages.debian.org/bullseye/bash/bash.1.en.html#HISTORY
HISTIGNORE="*=*" # but keep secrets secret
HISTSIZE=-1 # keep history of all commands entered, not just 500
PROMPT_COMMAND="history -a" # write memory to file on every command entered
shopt -s histappend # append to the file, don't overwrite it

##### Commands #####
# send ANSI color codes to the terminal
# # show me someone with a b&w CRT monitor
# # nvm: https://www.reddit.com/r/crtgaming/comments/u2nbu4/may_i_present_you_this_tiny_bw_crt_its_only_5/
alias ls='ls --color=always'
alias grep='grep --color=always'
alias diff='diff --color=always'
alias less="less --RAW-CONTROL-CHARS"
