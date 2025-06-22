git config --global user.name $USER
git config --global user.email $EMAIL
git config --global init.defaultBranch main

gh auth login \
  --git-protocol https \
  --web
