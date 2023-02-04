echo "Welcome $USER"
trap 'echo "Goodbye $USER, now on lvl $((SHLVL-1))"' EXIT

##### Fix the shell #####
# don't cache binary locations. search $PATH on every command entered
set +h

# globbing exists, it should at least work
shopt -s nullglob globstar dotglob
GLOBIGNORE=.:..

# tab tab tab
source /usr/share/bash-completion/bash_completion

##### History not Mystery #####
# https://manpages.debian.org/bullseye/bash/bash.1.en.html#HISTORY

# but keep secrets secret
HISTIGNORE="export *"
# keep history of all commands (not just 500) entered
HISTSIZE=-1
# append to the history file, don't overwrite it
shopt -s histappend
# write memory to history file on every command entered
PROMPT_COMMAND="history -a"

##### Commands #####
# send ANSI color codes to the terminal
# # show me someone with a b&w CRT monitor
# # nvm: https://www.reddit.com/r/crtgaming/comments/u2nbu4/may_i_present_you_this_tiny_bw_crt_its_only_5/
alias ls='ls --color=auto -h'
alias grep='grep --color=auto'
