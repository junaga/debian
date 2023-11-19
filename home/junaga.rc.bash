# CTRL+Backspace hotkey deletes a word
bind "\C-H":backward-kill-word

# See https://github.com/junaga/debian/blob/main/ps1.md
bold_blue="\[\e[1;34m\]"
reset="\[\e[0m\]"
PS1="\A $bold_blue\w$reset\$(__git_ps1 '|%s')\$ "
PS2="    "
PS4="$ "
unset bold_blue reset

# do more with less
export PAGER="less"
eval $(lesspipe)
alias less="less \
	--IGNORE-CASE \
	--tabs=2 --RAW-CONTROL-CHARS \
	--long-prompt"

# VS Code FTW
export EDITOR="code --wait"
source $(code --locate-shell-integration-path bash)

export BROWSER='echo CTRL+Click URL: '

# enable piping of `gh`
# https://cli.github.com/manual/gh_help_environment#:~:text=CLICOLOR_FORCE
export CLICOLOR_FORCE="true"
export GH_FORCE_TTY="100" # terminal width columns

##### Aliases #####
alias rm="trash-put"
alias hd="od -tx1 -cb"
function man { $BROWSER "https://manpages.debian.org/stable//$1..en.html"; }
alias tree="ls -AR -I "dist" -I ".git" -I "node_modules" -I ".next" -I "venv" -I "__pycache__""
alias time="date +%Y-%m-%d-%H-%M-%S"
alias fuck-windows="rm **/*Zone.Identifier"

alias e="code" # edit

alias dl="curl -sL"
alias js='node --unhandled-rejections=strict'
alias py='python3'
alias md5="md5sum"
alias fmt="npm run fmt"
alias build="npm run build"
alias dev="npm run dev &> devserver.log &"
alias python="python3"

function openai {
	# https://platform.openai.com/docs/api-reference/introduction

	local prompt="$1"

	curl -s https://api.openai.com/v1/completions \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-H "Content-Type: application/json" \
		-d "{ \"model\": \"text-davinci-003\", \"prompt\": \"$prompt\", \"max_tokens\": 100 }" \
		| jq --raw-output --monochrome-output ".choices[].text"
}

# debian:wireguard-tools dependency
function tunnel {
	# server $PORT needs to be on $HOST 0.0.0.0 to work
	curl https://tunnel.pyjam.as/$PORT > tunnel.conf && wg-quick up ./tunnel.conf
}
function tunnel-stop {
	wg-quick down ./tunnel.conf && rm ./tunnel.conf
}

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

##### Functions #####

function install {
	sudo apt install -y "$@"
}

function uninstall {
	sudo apt remove --purge -y "$@"
	sudo apt autoremove -y
}

function show {
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

function search {
	local command=$1
	local bin=$(type -P $command)
	local pkgname=$(dpkg --search $bin | sed 's/: .*//')
	echo $pkgname
}

function openai {
	# https://platform.openai.com/docs/api-reference/introduction

	local prompt="$1"

	curl -s https://api.openai.com/v1/completions \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-H "Content-Type: application/json" \
		-d "{ \"model\": \"text-davinci-003\", \"prompt\": \"$prompt\", \"max_tokens\": 100 }" \
		| jq --raw-output --monochrome-output ".choices[].text"
}

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
