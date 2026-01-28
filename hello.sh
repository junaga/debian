echo -e "\nList all files at Home"
ls -a --color ~/

echo -e "\nWrite, Read, Delete a file"
cd /tmp
echo "Hello, World!" >> hello.md
cat hello.md
rm hello.md

echo -en "\n(Cancel with CTRL+C) "
ping google.com

# echo "WSL only feature:"
# echo "Calling a Windows program, with Linux files!"
# explorer.exe .

echo -e "\nCDN Host:"
getent hosts deb.debian.org

echo -en "\nCPU Architecture: "
uname --machine

echo -en "\nUnix name: "
uname

echo -e "\nHost info:"
hostnamectl
