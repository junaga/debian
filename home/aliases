alias ls="ls --color=always --group-directories-first"
alias grep="grep --color=always"
# alias rm="trash-put"
alias date="date +%Y-%m-%d-%H-%M-%S"
function man { $BROWSER "https://manpages.debian.org/bookworm/$1.en"; }

# working with files
##########################
alias get="curl -sL"
function pack { tar -czvf $(realpath $1).tar.gz $1; }
function unpack { tar -xzvf $@ && rm $@; }

# fix file permissions
function colonize { chown -R $USER:$USER $1; }
function fuckdirs { find $1 -type d -exec chmod 755 {} +; }
function fuckfiles { find $1 -type f -exec chmod 644 {} +; }

# fix wsl.exe artifacts
function fuckwindows { find "$1" -type f -name '*Zone.Identifier' -delete; }

# play media files
alias audio="ffplay -hide_banner -autoexit -vn -nodisp"
alias video="ffplay -hide_banner -autoexit"

# system administration
##########################
function inst { sudo apt update; sudo apt install --yes $@; }
function uninst { sudo apt remove --purge --yes $@; sudo apt autoremove --yes; }

function terminal {
	echo TERM: $TERM 
	echo Device: $(tty)
	echo Baudrate: $(stty speed)
	echo Rows/Columns: $(stty size)
}
