# Hacked together bash shell prompt.
#
# ANSI Escape Sequences https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
# Bash prompt https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Controlling-the-Prompt
# "HH:MM" + " " + "ESC[Bold;Blue" + "PWD" + "ESC[Reset" + "Git branch" + "$ "
export PS1="\A \e[1;34m\w\e[0m\$(__git_ps1 '[%s]')$ "

# Allow quick hacking with a local ~/bin directory.
PATH=$PATH:$HOME/bin

# Configure Bash glob expansion
shopt -s dotglob globstar failglob
GLOBIGNORE='.:..'

# rename the master branch of an empty repo created with `git init`
alias main-lives-matter='git symbolic-ref HEAD refs/heads/main'

# Quickly run the firebase CLI
alias fire='npx firebase-tools --project $APP_PROJECT_ID'

# `apt show` the package of a binary in `$PATH``
function show-pkg {
  path=$(which "$1")
  pkg=$(dpkg -S "$path" | sed 's/: .*//')
  apt show "$pkg"
}
# list the binaries placed in `$PATH` from an installed package
function list-bin {
  pkg="$1"
  dpkg -L "$pkg" | grep -E "$(echo $PATH | tr ':' '|')"
}
