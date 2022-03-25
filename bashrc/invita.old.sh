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

##### system
# So files `rm`ed won't go to limbo
alias real-rm=$(which rm)
alias rm=trash

# Nobody likes node_modules
alias real-tree=$(which tree)
alias tree='tree -I "dist|node_modules"'
