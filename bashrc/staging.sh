#!/bin/bash
# Should work on wsl Debian.

# making requests with HTTPie, is a lot simpler then with curl.
alias https='http --default-scheme=https'
alias bash-options='echo $-'
alias bash-lvl='echo $SHLVL'

# Mount a Google Cloud Storage bucket localy in /mnt
function bucket {
  bucket=$1
  creds=$GOOGLE_APPLICATION_CREDENTIALS
  dir=/mnt/$bucket
  
  echo -e Mounting $dir with $creds\\n
  # This works because all buckets share a namespace
  sudo mkdir -p $dir
  sudo chown $USER:$USER $dir

  gcsfuse $bucket $dir
  echo Use \`sudo umount $dir\` to clear
}

##### I like the terminal
# So files `rm`ed won't go to limbo
alias real-rm=$(which rm)
alias rm=trash

# Nobody likes node_modules
alias real-tree=$(which tree)
alias tree='tree -I "dist|node_modules"'

mkcd() { mkdir "$1" && cd "$1"; }
alias l='ls -1 --group-directories-first'
alias ll='ls -lAh'
# such a long variable..
gCreds=GOOGLE_APPLICATION_CREDENTIALS

# git-igins
alias gitCommitAll="git add ./ && git commit"
alias gitAmendAll="git add ./ && git commit --amend --no-edit"
# run a command, commit all files, the commit msg is the command wrapped in ``$ MSG``
function gitCommitCmd {
  cmd=$1

  eval $cmd &&
  git add ./ &&
  git commit -m "\`$ $cmd\`"
}
