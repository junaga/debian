#!/bin/bash
# Invita bash shell rc file

##### The little things #####
export EDITOR='code --wait'
# Errors thrown in promises should kill!
alias run='node --unhandled-rejections=strict'
# quick maths
versions() {
  node --version
  yarn --version
  git --version
  bash --version
}


##### I like the Terminal #####
mkcd() { mkdir "$1" && cd "$1"; }
alias l='ls -1 --group-directories-first'
alias ll='ls -lAh'
# such a long variable..
gCreds=GOOGLE_APPLICATION_CREDENTIALS

# Usefull for dotenv (`.env`) files. # https://github.com/motdotla/dotenv
# Create a new shell process with the environment variables from the file.
# Use `exit` to leave, effectively unloading the environment variables.
#
# i.e. `$ enter prod.env ../myvars.env`
# Variables in `myvars.env` overwrite `prod.env`
enter() {
  scripts=$@
  echo "Use \`exit\` to leave"
  bash --rcfile <(echo "
    source ~/.bashrc

    set -a
    for script in $scripts
      do source \$script
      done
    set +a
  ")
}
