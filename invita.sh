#!/bin/bash
# Should work on wsl Debian.
# Invita bash shell rc.


##### random intro
# Hi :D This file got placed in your home directory (~) because you ran the install.sh script.
# Please edit, no.. you have to edit! - this file to suite your needs. Delete this comment, etc.
# If you wanna check out what new helpers got added to the 'system/files/shellrc' default,
# with vscode you could for example do: `code --diff ~/shellrc ~/invita/system/files/shellrc`
# Also check out our recommended packages from `system/dependencies` with i.e. `wajig show PKG`
echo Hi! :D from shellrc



##### WSL 2
# so you can `cd $windows` or `mv $windows/Downloads/1.jpg ./` 
windows=/mnt/c/Users/Hermann

# when placing files from windows in linux, they are owned by root.
# fix all files recursively by running `my-files` in the directory 
alias my-files='sudo chown $USER:$USER -R ./'



##### web dev
# VS Code is our default text editor.
export EDITOR='code --wait'

# check dns records of a domain. See also: https://toolbox.googleapps.com/apps/dig/
alias dns='dig +noall +answer'
# turn a directory into a static file server with two words
alias website='python3 -m http.server 8080 --directory'
# making requests with HTTPie, is a lot simpler then with curl.
alias https='http --default-scheme=https'

# `export` environment variables, from a .env file, into the current shell process.
# WARNING: This can be dangerous, DONT RUN MORE THEN ONCE.
# Because it does not "unset" previously exported vars, as one might expect.
# Generally it is better to set your env variables manually one by one, per shell session.
function export-all {
  file=$1

  set -a
  source $file
  set +a
}

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
alias tree='tree -I node_modules'

# faaaasteeer
function mkcd() { mkdir "$1" && cd "$1"; }
alias l='ls -1'
alias ll='ls -lAh'
