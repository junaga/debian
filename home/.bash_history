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
echo $PWD
bash --login
code src/debian/
man bash
mv .bash_history src/debian/home/
tldr git config
git config --global user.name junaga
git config --global user.email hermann-stanew@invita.gmbh
