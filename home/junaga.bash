export EMAIL="hermann-stanew@invita.gmbh"
export EDITOR="code --wait -" # https://code.visualstudio.com/
export PAGER="/bin/more"
export SHELL="/bin/bash"
export BROWSER="/bin/echo BROWSER: " # brave-browser-stable

alias e=$EDITOR
alias py="python3"
alias js="node --unhandled-rejections=strict"
alias get="curl -sL"

# alias rm="trash-put"
function man { $BROWSER "https://manpages.debian.org/bookworm/$1.en"; }
function inst { sudo apt update; sudo apt install --yes $@; }
function uninst { sudo apt remove --purge --yes $@; sudo apt autoremove --yes; }

function pack {
  local file=$(realpath $1)
	tar -czvf $file.tar.gz $1
}

function unpack {
	tar -xzvf $@ && rm $@
}

function terminal {
	echo TERM: $TERM 
	echo Device: $(tty)
	echo Baudrate: $(stty speed)
	echo Rows/Columns: $(stty size)
}

alias datetime="date +%Y-%m-%d-%H-%M-%S"
alias audio="ffplay -hide_banner -autoexit -vn -nodisp"
alias video="ffplay -hide_banner -autoexit"

# wsl.exe artifacts
function fuckwindows { find "$1" -type f -name '*Zone.Identifier' -delete; }

function colonize { chown -R $USER:$USER $1; }
function fuckdirs { find $1 -type d -exec chmod 755 {} +; }
function fuckfiles { find $1 -type f -exec chmod 644 {} +; }
