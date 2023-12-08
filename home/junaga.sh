# me: hms, jun, rbt

echo "Welcome $USER"
trap "echo \"Goodbye $USER. Now on lvl $((SHLVL-1))\"" EXIT

export PATH="$PATH:./node_modules/.bin/" # deb:nodejs
export BROWSER="echo CTRL+Click: " # TODO: set to `chromium`
export EDITOR="code --wait" # https://code.visualstudio.com/

################
## fix colors ##

alias ls="ls --color=always"
alias grep="grep --color=always"
export CLICOLOR_FORCE="true" # https://cli.github.com/manual/gh_help_environment#:~:text=CLICOLOR_FORCE

################
## aliases    ##

alias e="code" # edit
# alias g # google
# alias v # https://github.com/junaga/v-vcs

alias rm="trash-put"
alias python="python3"
alias whenisit="date +%Y-%m-%d-%H-%M-%S"
alias fuckwindows="rm **/*Zone.Identifier"

# x-man-page://
function man {
	$BROWSER "https://manpages.debian.org/$1.en"
}

function tunnel { # deb:wireguard-tools
	# server $PORT needs to be on $HOST 0.0.0.0 to work
	curl https://tunnel.pyjam.as/$PORT > tunnel.conf && wg-quick up ./tunnel.conf
}
function tunnel-stop { # deb:wireguard-tools
	wg-quick down ./tunnel.conf && rm ./tunnel.conf
}

function pack {
	tar -czvf "$(realpath "$1").tar.gz" "$1"
}
function unpack {
	if tar -xzvf "$@"; then
		rm "$@"
	fi
}

################
## Debug      ##

function debug_terminal {
	echo \$TERM: $TERM 
	echo Device: $(tty)
	echo Baudrate: $(stty speed)
	echo Rows Columns: $(stty size)
}

function debug_bash {
	rm bash-options.log

	echo "$ echo \$-" >> bash-options.log
	echo $- >> bash-options.log
	echo "$ echo \$BASHOPTS" >> bash-options.log
	echo $BASHOPTS >> bash-options.log
	echo "$ shopt -p" >> bash-options.log
	shopt -p >> bash-options.log
	echo "$ declare -p" >> bash-options.log
	declare -p >> bash-options.log
	echo "$ set" >> bash-options.log
	set >> bash-options.log

	set -vx
	# RTFM the bash manual - :skull: :crying:
	man bash
}

function debug_apt {
	local pkg=$1
	
	apt show $pkg
	
	dpkg -s $pkg | grep --color=never "Status: "
	stat /var/lib/dpkg/info/$pkg.list | grep --color=never Modify
	
	echo Binaries:
	dpkg --listfiles $pkg | grep --color=never \
		-e ^/usr/local/sbin/ -e ^/usr/local/bin/ \
		-e ^/usr/sbin/ -e ^/usr/bin/ \
		-e ^/sbin/ -e ^/bin/
	
	echo Config:
	dpkg --listfiles $pkg | grep --color=never \
		/etc/

	echo Bash completions:
	dpkg --listfiles $pkg | grep --color=never \
		/usr/share/bash-completion/completions/
}
