export EMAIL="hermann-stanew@invita.gmbh"
export EDITOR="code --wait -" # https://code.visualstudio.com/
export PAGER="/bin/more"
export SHELL="/bin/bash"
export BROWSER="/bin/echo BROWSER: " # brave-browser-stable

function man { $BROWSER "https://manpages.debian.org/$1.en"; }
alias python="python3"
alias datetime="date +%Y-%m-%d-%H-%M-%S"
alias audio="ffplay -hide_banner -autoexit -vn -nodisp"
alias video="ffplay -hide_banner -autoexit"
alias fuckwindows="find . -type f -name '*Zone.Identifier' -delete" # wsl.exe artifacts
