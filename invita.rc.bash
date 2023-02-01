echo "Welcome $USER"
trap 'echo "Goodbye $USER, now lvl $((SHLVL-1))"' EXIT

##### Fix the shell #####
# don't cache binary locations. search $PATH on every command entered
set +h

# send ANSI color codes to the terminal
# # show me someone with a b&w CRT monitor
# # nvm: https://www.reddit.com/r/crtgaming/comments/u2nbu4/may_i_present_you_this_tiny_bw_crt_its_only_5/
alias ls='ls --color=auto -h'
alias grep='grep --color=auto'

# tab tab tab
source /usr/share/bash-completion/bash_completion

##### History not Mystery #####
# https://manpages.debian.org/bullseye/bash/bash.1.en.html#HISTORY

HISTIGNORE="export *" # but keep secrets secret
HISTSIZE=-1 # keep history of all commands (not just 500) entered
shopt -s histappend # append to the history file, don't overwrite it
PROMPT_COMMAND="history -a" # write memory to history file on every command entered

##### We work with #####
export PAGER="less"
export EDITOR="code --wait" # VS Code FTW
# unset XDG_CURRENT_DESKTOP # We don't need no desktop
# export BROWSER="chrome" # everything is chrome in the future
