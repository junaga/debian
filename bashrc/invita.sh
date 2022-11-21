#!/bin/bash
# Invita bash shell rc file

echo Welcome $USER

# VS Code everything
export EDITOR='code --wait'
# If it has to be used..
export PAGER='less'

# TODO: This is actually bad. We should not `source` the file.
#
# Create a new shell instance, with the variables from
# a dotenv (`.env`) file, set into the process environment.
# Quit the shell, and the environment disappears.
#
# https://github.com/motdotla/dotenv
# For example: `$ enter prod.env ../myvars.env`,
# variables in `myvars.env` overwrite `prod.env`
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


##### The little things #####
# Errors thrown in promises should kill!
alias run='node --unhandled-rejections=strict'

versions() {
  echo node: $(node --version)
  echo git: $(git --version)
  echo bash: $BASH_VERSION
}
