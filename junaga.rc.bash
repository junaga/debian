##### Customized Prompt #####
export PATH=$PATH:$HOME/bin
set -C # redirection (`>`) overwites' error out

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

# HH:MM+" "+BLUE;BOLD+PWD+RESET+<"|"+GIT_BRANCH>+"$"+" "
PS1="\A \[\e[34;1m\]\w\[\e[m\]\$(__git_ps1 '|%s')$ "
PS2="  "


##### Aliases #####
alias time='date +"%Y-%m-%dT%H:%M:%S%:z"'
alias rm="trash-put"
function man { echo "CTRL+Click: https://manpages.debian.org/bullseye//$1..en.html"; }

alias e="code"
alias vs="code --diff"
alias js='node --unhandled-rejections=strict'
alias md5="md5sum"
alias main-lives-matter='git symbolic-ref HEAD refs/heads/main'

function pack {
  tar -czvf "$(realpath "$1").tar.gz" "$1"
}
function unpack {
  if tar -xzvf "$@"; then
    rm "$@"
  fi
}


##### Custom Functions #####
function inst {
  (echo "===== Debian (\`apt\`) =====" && sudo apt install -y "$1") ||
  (echo "===== Python (\`pip\`) =====" && sudo pip install "$1") ||
  (echo "===== Node (\`npm\`) =====" && sudo npm install --global "$1")
}
function show {
  (echo "===== Debian (\`apt\`) =====" && apt show "$1") ||
  (echo "===== Python (\`pip\`) =====" && pip show "$1") ||
  (echo "===== Node (\`npm\`) =====" && npm show "$1")
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
