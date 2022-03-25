alias gitCommitAll="git add ./ && git commit"
alias gitAmendAll="git add ./ && git commit --amend --no-edit"

# run a command, commit all files, the commit msg is the command wrapped in ``$ MSG``
function gitCommitCmd {
  cmd=$1

  eval $cmd &&
  git add ./ &&
  git commit -m "\`$ $cmd\`"
}

# rename the master branch of an empty repo created with `git init`
alias main-lives-matter='git symbolic-ref HEAD refs/heads/main'

# Hacked together bash shell prompt.
# ANSI Escape Sequences https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
# Bash prompt https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Controlling-the-Prompt
#
# "HH:MM" + " " + "ESC[Bold;Blue" + "PWD" + "ESC[Reset" + "Git branch" + "$ "
export PS1="\A \e[1;34m\w\e[0m\$(__git_ps1 '[%s]')$ "
