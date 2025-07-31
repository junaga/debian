# `Git` -> `GitHub` quick setup

# Sets global Git name and email, switches default branch to `main`,
# then runs an interactive GitHub CLI login over HTTPS.

git config --global user.name $USER
git config --global user.email $EMAIL
git config --global init.defaultBranch main

gh auth login \
  --git-protocol https \
  --web
