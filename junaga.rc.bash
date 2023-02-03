##### Customized Prompt #####
export PATH=$PATH:$HOME/bin
set -C # redirection (`>`) overwites' error out

# Bash prompt variables
# https://manpages.debian.org/stretch/bash/bash.1.en.html#PROMPTING

# Terminal, ANSI Escape Code, Control Sequence Introducer, Select Graphic Rendition, Parameters (or simply ANSI color codes)
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters
#
# ANSI Color codes syntax
# "\[\e[" + $CODE + "m\]" + $TEXT + "\[\e[m\]"
# where $CODE is one or multiple color codes separated by ";"
# and $TEXT is the text to be colored.
# The closing sequence "\[\e[m\]" resets all color codes.
#
# ANSI Escape codes are parsed by the terminal emulator not the shell.
# So the shell won't misscount printed characters (line wrapping issues),
# escape the color codes with "\[" "\]"
# Otherwise the shell and terminal cursor position will get out of sync.

blue_bold='\[\e[34;1m\]'
reset='\[\e[m\]'

# "HH:MM"+" "+PWD+<"|"+GIT_BRANCH>+"$"+" "
PS1="\A $blue_bold\w$reset\$(__git_ps1 '|%s')$ "
PS2="  "
unset blue_bold reset

# CTRL + Backspace hotkey to delete a word
bind '"\C-H":backward-kill-word'


##### Aliases #####
alias rm="trash-put"
alias time='date +"%Y-%m-%dT%H:%M:%S%:z"'
function man { echo "CTRL+Click: https://manpages.debian.org/bullseye//$1..en.html"; }

alias e="code"
alias dl="curl --location"
alias js='node --unhandled-rejections=strict'
alias md5="md5sum"
alias main-lives-matter='git symbolic-ref HEAD refs/heads/main'
alias baudrate="stty --file \$(tty) speed"

function pack {
	tar -czvf "$(realpath "$1").tar.gz" "$1"
}
function unpack {
	if tar -xzvf "$@"; then
		rm "$@"
	fi
}


##### Package management #####
function inst {
	(echo "===== Debian (\`apt\`) =====" && sudo apt install -y "$1") ||
	(echo "===== Python (\`pip\`) =====" && sudo pip install "$1") ||
	(echo "===== Node (\`npm\`) =====" && sudo npm install --global "$1")
}
function show {
	(echo "===== Debian (\`apt\`) =====" && apt show "$@")
	(echo "===== Python (\`pip\`) =====" && pip show "$@")
	(echo "===== Node (\`npm\`) =====" && npm show "$@")
}

function search-pkg {
	if [ "$(type -a "$1" | wc -l)" -gt 1 ];
	then
		echo -e "multiple binaries found:\n" && type -a "$1" >&2
		return 1
	else
		echo -e "type $(type "$1") placed by:\n"
		apt show "$(dpkg --search "$(type -P "$1")" | sed 's/: .*//')"
	fi
}

function list-pkg-bins {
	dpkg --listfiles "$1" | \
	grep -E "$(echo "$PATH" | tr ':' '|')"
}
