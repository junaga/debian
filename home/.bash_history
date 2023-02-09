cd ..
tldr git
tldr git
type tldr
mkdir src
cd src
git clone https://github.com/junaga/debian
cd ..
diff -r src/debian/ old/debian-main/
cp old/debian-main/ src/debian/
cp -r old/debian-main/ src/debian/
diff -r src/debian/ old/debian-main/
mv old/debian-main/ src/debian/
tldr mv
tldr cp
cp -r old/debian-main/ src/debian/
diff -r src/debian/ old/debian-main/
cat src/debian/install/upgrade.bash | less
mv old/debian-main/install/upgrade.bash src/debian/install/upgrade.bash 
diff -r src/debian/ old/debian-main/
diff -r src/debian/ old/debian-main/
cd src/debian/
git status
sudo bash -e debian-main/setup.bash 
bash --login
code src/debian/
man bash
mv .bash_history src/debian/home/
tldr git config
git config --global user.name junaga
git config --global user.email hermann-stanew@invita.gmbh
cd src/debian/
git push 
git push 
# awsome, VS Code just signed me in. by itself. with a popup into my browser. in an OAuth flow. i was already signed into github.com it just took the token XD
git add home/
git status
git commit -m "this feels great"
git push 
git add home/
git commit -m "repeat" && git push
man bash
bash --login
man bash
cd /etc
cat bash_completion.d/git-prompt 
bash --login
bash --login
man bash
bash --login
cd src/debian/
cat /etc/inputrc 
code /etc/inputrc 
apt show readline
dpkg --search /etc/inputrc 
dpkg --search /etc/inputrc 
show xsel
bash --login
function man { $BROWSER "https://manpages.debian.org/stable//$1..en.html"; }
alias time="date +%Y-%m-%d-%H-%M-%S"
time
baudrate
stty
stty --help
apt show stty
type stty
type -p stty
dpkg --search $(type -p stty)
dpkg --search /sbin/stty
dpkg --search /bin/stty
tldr stty
stty --all
tldr tty
tty
stty --all
stty 
tty
dpkg --search $(type -p tty)
dpkg --search $(type -p stty)
dpkg --search /bin/stty
tldr stty
stty
stty --all
stty --help
stty speed
stty man stty
man stty
env 
env  | grep TERM
function terminal { 	echo 	TERM: $TERM 	Baudrate: $(stty speed); }
terminal 
function terminal { 	echo -e 	TERM: $TERM \n	Baudrate: $(stty speed); }
terminal 
cd ~
mkdir test && cd $_
git init
git config --global init.defaultBranch main
cd ~
rm -r test/
env rm -r .local/
function terminal { 	echo \$TERM: $TERM ; 	echo Device: $(tty); 	echo Baudrate: $(stty speed); 	echo Rows/Columns: $(stty size); }
terminal 
bash --login
type rm
type -a rm
type -a time
help time
type /bin/bash
type -p /bin/bash
type -p /etc/apt/sources.list
type -p /etc/apt/sources.list.d/
type -p /etc/apt/sources.list.d/
type /etc/apt/sources.list.d/
type /etc/apt/sources.list
dpkg --listfiles apt | grep /etc/apt
type -p bash
type -P bash
type --help
type ls
type -t ls
type -p ls
type -P ls
function find-pkg { 	local command=$1; 	local bin=type -P $command; 	dpkg --search $bin; }
find-pkg ls
type -P ls
function find-pkg { 	local command=$1; 	local bin=$(type -P $command); 	dpkg --search $bin; }
find-pkg ls
find-pkg /bin/ls
type -a ls
type -a bash
dpkg --help
findfs
findfs --help
function search { 	local command=$1; 	local bin=$(type -P $command); 	local pkgname=$(dpkg --search $bin | sed 's/: .*//'); 	echo $pkgname; }
search ls
search /bin/ls
search /bin/bash
search /bin/stty
search /bin/tty
search tty
search /usr/bin/tty
type -a tty
function show { 	local pkgname=$1	 	apt show $pkgname; 	echo Binaries:; 	dpkg --listfiles $pkgname | grep 		-e /usr/local/sbin/ -e /usr/local/bin/ 		-e /usr/sbin/ -e /usr/bin/ 		-e /sbin/ -e /bin/; 	echo Bash completions:; 	dpkg --listfiles bash-completion | 		grep /usr/share/bash-completion/completions/ | 		grep $pkgname; }
function show { 	local pkgname=$1	 	apt show $pkgname; 	echo Binaries:; 	dpkg --listfiles $pkgname | grep 		-e "^/usr/local/sbin/" -e "^/usr/local/bin/" 		-e "^/usr/sbin/" -e "^/usr/bin/" 		-e "^/sbin/" -e "^/bin/"; 	echo Bash completions:; 	dpkg --listfiles bash-completion | 		grep /usr/share/bash-completion/completions/ | 		grep $pkgname; }
show nodejs
dpkg --listfiles nodejs
dpkg --listfiles nodejs | grep bin
show nodejs
	dpkg --listfiles nodejs | grep 		-e ^/usr/local/sbin/ -e ^/usr/local/bin/ 		-e ^/usr/sbin/ -e ^/usr/bin/ 		-e ^/sbin/ -e ^/bin/
	dpkg --listfiles nodejs | grep --color=off 		-e ^/usr/local/sbin/ -e ^/usr/local/bin/ 		-e ^/usr/sbin/ -e ^/usr/bin/ 		-e ^/sbin/ -e ^/bin/
	dpkg --listfiles nodejs | grep --color=never 		-e ^/usr/local/sbin/ -e ^/usr/local/bin/ 		-e ^/usr/sbin/ -e ^/usr/bin/ 		-e ^/sbin/ -e ^/bin/
cd /usr/share/bash-completion/
cd completions/
dpkg --search $PWD/git
dpkg --search $PWD/lsblk
dpkg --search $PWD/man
dpkg --search $PWD/rm
dpkg --search $PWD/echo
dpkg --search $PWD/bash
dpkg --listfiles bash-completion | grep $PWD
dpkg --search $PWD/sudo
apt show nodejs
dpkg-query -l nodejs
dpkg -s nodejs
apt show nodejs
apt show nodejs > ~/apt
dpkg -s nodejs > ~/dpkg
diff ~/{apt,dpkg}
e -d ~/{apt,dpkg}
dpkg -s nodejs | grep "Status: "
cat /var/lib/dpkg/info/nodejs.list 
stat /var/lib/dpkg/info/nodejs.list 
stat /var/lib/dpkg/info/nodejs.list | grep Modify
dpkg -s nodejs | env grep "Status: "
dpkg -s nodejs | env grep "Status: "
alias ls='echo hi'
function do_stuff { ls; }
do_stuff 
function show { 	local pkg=$1	 	apt show $pkg; 	dpkg -s $pkg | grep --color=never "Status: "; 	stat /var/lib/dpkg/info/$pkg.list | grep --color=never Modify; 	echo Binaries:; 	dpkg --listfiles $pkg | grep --color=never 		-e ^/usr/local/sbin/ -e ^/usr/local/bin/ 		-e ^/usr/sbin/ -e ^/usr/bin/ 		-e ^/sbin/ -e ^/bin/; 	echo Bash completions:; 	dpkg --listfiles bash-completion | 		grep /usr/share/bash-completion/completions/ | 		grep $pkg; }
show nodejs
cd /usr/share/bash-completion/completions/ 
dpkg --search $PWD/dpkg
dpkg --search $PWD/apt
dpkg --search $PWD/sudo
dpkg --search $PWD/node
dpkg --search $PWD/nodejs
dpkg --search $PWD/npm
function show { 	local pkg=$1	 	apt show $pkg; 	dpkg -s $pkg | grep --color=never "Status: "; 	stat /var/lib/dpkg/info/$pkg.list | grep --color=never Modify; 	echo Binaries:; 	dpkg --listfiles $pkg | grep --color=never 		-e ^/usr/local/sbin/ -e ^/usr/local/bin/ 		-e ^/usr/sbin/ -e ^/usr/bin/ 		-e ^/sbin/ -e ^/bin/; 	echo Bash completions:; 	dpkg --listfiles $pkg | grep --color=never 		/usr/share/bash-completion/completions/; }
show apt
show apt
show apt
show sudo
sudo --help 
cd ~
rm apt dpkg 
sudo bash -e src/debian/install/upgrade.bash 
cd ~
code src/debian/home/.bash_history 
cd src/debian/
git push
# not required in VMs
rm -r /lost+found/
rm -r /boot/
rm -r /media/
rm -r /root/
rm -r /var/spool/
sudo su
apt list --installed  | wc
apt-mark showmanual | wc
sudo bash -e install/upgrade.bash 
cd ~
env rm .local/
env rm  -r .local/
cd src/debian/
git branch
git branch uninstall
git checkout uninstall 
git checkout main
git checkout uninstall 
git push
git push origin uninstall 
git checkout main 
bash --login
cd src/
cd debian/
cd ..
cd ..
mkdir new
cd new
node --version
npm init
npm --help
cd src/debian/
git status
git push
git checkout uninstall 
git push
git push --set-upstream origin uninstall 
git checkout main 
cd ..
git clone https://github.com/junaga/v-vcs
cd v-vcs/
python
show python3
code ~/src/debian/install/packages 
apt rdepends python3
apt rdepends --installed python3
apt rdepends --installed python3-apt
apt rdepends --installed command-not-found
show python3
python3
type python3
type -P python3
type -a python3
dpkg --search /usr/bin/python3
pdb3
show python
show python3
dpkg --search /usr/bin/python3
apt show python3-minimal
pip
pip3
show python3-pip
install python3-pip
install python3-pip
install python3-pip
sudo apt install --eror-on=any -y python3-pip
sudo apt install -y --error-on=any python3-pip
sudo apt --error-on=any install -y python3-pip
sudo apt install -y python3-pip
install python3-pip
install python3-pip
show python3-pip
pip --version
python
python3
python3 --version
type -a python3
dpkg --search /bin/python3
dpkg --search /usr/bin/python3
show python3-minimal
dpkg --listfiles python3-minimal
apt show python3
show python3
show python3-minimal
show python3
dpkg --listfiles python3
apt search python3
install python3-pip
bash --login
py --help
py --version
man python
man python3
cd src/
cd v-vcs/
py bin.py 
pip install --upgrade --requirement dependencies 
pip list
py -m black ./
git status
alias v="python3 -m $PWD/bin.py"
cd ~
v
pip --version
py --version
alias tree="ls -AR"
tree
tree src
man ls
alias tree="ls -AR --ignore=".git/""
tree src
code src/debian/home/junaga.rc.bash 
alias tree="ls -AR --ignore=".git""
tree src
alias tree="ls -AR --ignore=".git" --ignore="node_modules" --ignore="__pycache__""
tree src
tree ./
cat .python_history 
alias tree="ls -AR --ignore=".git" --ignore="node_modules" --ignore="venv" --ignore="__pycache__""
tree src
tree .local/
tree .local/ | less
man less
tldr less
tree .local/ | less
tree .local/ | less
tree src/
tree new
alias tree="ls -AR -I="dist" -I=".git" -I="node_modules" -I="venv" -I="__pycache__""
tree src
alias tree="ls -AR -i="dist" -i=".git" -i="node_modules" -i="venv" -i="__pycache__""
tree src
alias tree='ls -AR -i="dist" -i=".git" -i="node_modules" -i="venv" -i="__pycache__"'
tree src
man ls
alias tree="ls -AR -I "dist" -I ".git" -I "node_modules" -I "venv" -I "__pycache__""
tree src
tree src
tree new
cd src/
git clone http://github.com/junaga/snippets
code -d /mnt/c/Users/junaga/AppData/Roaming/Code/User/settings.json snippets/readme.md 
code snippets/readme.md 
code --help
source $(code --locate-shell-integration-path bash)
tldr git commit
tree
curl -L https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview | less
bash --login
tree src
code src/snippets/readme.md 
e src/snippets/javascript.md 
cd src/snippets/
git log
npm --version
