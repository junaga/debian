# commit all files in working dir
alias commit-all="git add ./ && git commit"

# run a command, commit all files, the commit msg is the command
function commit-cmd {
  cmd=$1

  eval $cmd &&
  git add ./ &&
  git commit -m "\`$cmd\`"
}

# rename the master branch of an empty repo created with `git init`
alias main-lives-matter='git symbolic-ref HEAD refs/heads/main'
