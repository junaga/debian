git config --global user.name $USER
git config --global user.email $EMAIL
git config --global init.defaultBranch main
git config --global alias.glog "log --all --graph --date=short --pretty=format:'%C(yellow)%h %C(white)%an %ad %s %C(auto) %d %Creset'"

gh auth login \
  --git-protocol https \
  --web
