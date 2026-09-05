#!/usr/bin/env bash

set -euo pipefail

function inst { code --install-extension "$1"; }

inst ms-vscode-remote.remote-ssh # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh
inst ms-vscode-remote.remote-containers # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers
inst PKief.material-icon-theme # https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme
inst ozaki.markdown-github-dark # https://marketplace.visualstudio.com/items?itemName=ozaki.markdown-github-dark
inst Vue.volar # https://marketplace.visualstudio.com/items?itemName=Vue.volar
