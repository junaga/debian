##### My prompt #####
# CTRL+Backspace hotkey deletes a word
bind "\C-H":backward-kill-word

# See https://github.com/junaga/debian/blob/main/ps1.md
bold_blue="\[\e[1;34m\]"
reset="\[\e[0m\]"
PS1="\A $bold_blue\w$reset\$(__git_ps1 '|%s')\$ "
PS2="    "
PS4="$ "
unset bold_blue reset

export PAGER="less" # do more with less
export EDITOR="code --wait" # VS Code FTW
export BROWSER='echo CTRL+Click URL: '

##### Aliases #####
alias rm="trash-put"
alias hd="od -tx1 -cb"
function man { $BROWSER "https://manpages.debian.org/stable//$1..en.html"; }
alias time="date +%Y-%m-%d-%H-%M-%S"

# b is Bing
alias e="code" # edit
# g is Google
alias dl="curl -L"
alias js='node --unhandled-rejections=strict'
alias md5="md5sum"

function terminal {
	echo \$TERM: $TERM 
	echo Device: $(tty)
	echo Baudrate: $(stty speed)
	echo Rows/Columns: $(stty size)
}

function pack {
	tar -czvf "$(realpath "$1").tar.gz" "$1"
}
function unpack {
	if tar -xzvf "$@"; then
		rm "$@"
	fi
}

##### Package management #####
function install {
	sudo apt install --error-on=any -y "$@"
}
function uninstall {
	sudo apt remove --error-on=any --purge -y "$@"
	sudo apt autoremove -y
}

function show {
	pkgname="$1"
	
	apt show $pkgname
	echo Binaries:
	dpkg --listfiles $pkgname | grep \
		-e /usr/local/sbin/ -e /usr/local/bin/ \
		-e /usr/sbin/ -e /usr/bin/ \
		-e /sbin/ -e /bin/
	echo Bash completions:
	dpkg --listfiles bash-completion | \
		grep /usr/share/bash-completion/completions/ | \
		grep $pkgname

	unset pkgname
}

function pkg-bin {
	if [ "$(type -a "$1" | wc -l)" -gt 1 ];
	then
		echo -e "multiple binaries found:\n" && type -a "$1" >&2
		return 1
	else
		echo -e "type $(type "$1") placed by:\n"
		apt show "$(dpkg --search "$(type -P "$1")" | sed 's/: .*//')"
	fi
}
