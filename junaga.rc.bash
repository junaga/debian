##### Aliases #####
alias time='date +"%Y-%m-%dT%H:%M:%S%:z"'
alias rm="trash-put"
alias diff="code --diff"
function man { echo "CTRL+Click: https://manpages.debian.org/bullseye//$1..en.html"; }

alias js='node --unhandled-rejections=strict'
alias main-lives-matter='git symbolic-ref HEAD refs/heads/main'

##### Custom Functions #####
function inst {
  (echo "===== Debian (\`apt\`) =====" && sudo apt install -y "$1") ||
  (echo "===== Python (\`pip\`) =====" && sudo pip install "$1") ||
  (echo "===== Node (\`npm\`) =====" sudo npm install --global "$1")
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
