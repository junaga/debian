echo -en "CPU Architecture: "; uname --machine
echo -en "Unix name: "; uname
hostnamectl | grep --color=no "Operating System"

echo -e "\nWrite, Read, Delete a file..."
cd /tmp
echo "Hello, World!" >> hello.md
cat hello.md
rm hello.md

echo -e "\nList files..."
ls --color ~/

# echo "WSL only feature:"
# echo "Calling a Windows program, with Linux files!"
# explorer.exe .

echo -e "\nEmoji in the Terminal..."
echo "Emoji 2015: 😂 ❤️ 👍 😭"
echo "Emoji 2015: 🖕 🖖 🤘 👁️‍🗨️"
echo "Emoji 2016: 🤣 🤡 🥑 🤳"
echo "Emoji 2016: 🤦 🤷 🏳️‍🌈 👩‍💻"
echo "Emoji 2017: 🤯 🤩 🧠 🦖"
echo "Emoji 2018: 🥺 🥳 🧸 🥯"
echo "Emoji 2019: 🥱 🤏 🦥 🧄"
echo "Emoji 2019: 🧑‍🦰 🧑‍🦱 🧑‍🦳 🧑‍🦲"
echo "Emoji 2020: 🥲 🥸 🤌 🏳️‍⚧️"
echo "Emoji 2020: 😮‍💨 😵‍💫 ❤️‍🔥 ❤️‍🩹"
echo "Emoji 2021: 🫠 🫡 🫶 🫦"
echo "Emoji 2022: 🩷 🫨 🫎 🪿"
echo "Emoji 2023: 🐦‍🔥 🍋‍🟩 🍄‍🟫 ⛓️‍💥"
echo "Emoji 2024: 🫩 🫆 🪾 🪏"
echo "Emoji 2026: 🫪 🫯 🫍 🪎"

echo -en "\n(CTRL+C: Cancel) "
timeout 3 ping google.com

echo -e "\nDebian CDN..."
getent hosts deb.debian.org

echo
echo "Audio and Mic..."
echo "==================="
echo "Test speak now (3s)"
echo "==================="
timeout 3 pw-record /tmp/test.wav
echo "Playing back..."
pw-play /tmp/test.wav
