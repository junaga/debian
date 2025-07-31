# aliases
##########################
python() { python3 "$@"; }
open() { $BROWSER "$@"; }
edit() { $EDITOR "$@"; }
copy() { xclip -selection clipboard "$@"; }
play() { ffplay -hide_banner -autoexit "$@"; }
audio() { ffplay -hide_banner -autoexit -vn -nodisp "$@"; }

ls() { env ls --color=always --group-directories-first "$@"; }
grep() { env grep --color=always "$@"; }
date() { env date +%Y-%m-%d-%H-%M-%S "$@"; }
man() { $BROWSER "https://manpages.debian.org/bookworm/$1.en"; }
# rm() { trash-put "$@"; }

# working with files
##########################
get() { curl -sSfL "$@"; }
pack() { tar -czvf $(realpath "$1").tar.gz "$1"; }
unpack() { tar -xzvf "$1" && rm "$1"; }

# fix file permissions
colonize() { sudo chown -R $USER:$USER "$1"; }
fuckdirs() { find "$1" -type d -exec chmod 755 {} +; }
fuckfiles() { find "$1" -type f -exec chmod 644 {} +; }

# fix wsl.exe artifacts
fuckwindows() { find "$1" -type f -name "*Zone.Identifier" -delete; }

# system administration
##########################
inst() { sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends --yes "$@"; }
uninst() { sudo apt remove --purge --yes "$@"; sudo apt autoremove --yes; }
binaries() { dpkg -L "$1" | grep -E "^($(echo "$PATH" | tr ":" "|"))/"; }

terminal() {
	echo TERM: $TERM 
	echo Device: $(tty)
	echo Baudrate: $(stty speed)
	echo Rows/Columns: $(stty size)
}
