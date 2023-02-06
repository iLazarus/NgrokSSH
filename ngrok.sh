#!/bin/bash

if [[ -z "$NGROK_TOKEN" ]]; then
  echo "Please set 'NGROK_TOKEN'"
  exit 2
fi

if [[ -z "$USER_PASS" ]]; then
  echo "Please set 'USER_PASS' for user: $USER"
  exit 3
fi

echo "### Update user: $USER password ###"
echo -e "$USER_PASS\n$USER_PASS" | sudo passwd "$USER"

echo "### Update user: root password ###"
echo -e "$USER_PASS\n$USER_PASS" | sudo passwd root

# echo "### Switch to root ###"
# echo -e "$USER_PASS\n$USER_PASS" | sudo apt install expect
# sudo su - root

echo "Current user: $(whoami)"
echo "PWD: $(pwd)"

echo "### Install ngrok ###"
#wget -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip
#unzip ngrok-stable-linux-386.zip
wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -zxf ngrok-v3-stable-linux-amd64.tgz
chmod +x ./ngrok

echo "### Start ngrok proxy for 22 port ###"
rm -f .ngrok.log
./ngrok authtoken "$NGROK_TOKEN"
sleep 5
#/home/runner/.config/ngrok/ngrok.yml
echo -e "tunnels:\n  ssh:\n    addr: 22\n    proto: tcp\n  web:\n    addr: 80\n    proto: http\n">>/home/runner/.config/ngrok/ngrok.yml
#cat /home/runner/.config/ngrok/ngrok.yml
./ngrok start --all --log ".ngrok.log" &
sleep 10
HAS_ERRORS=$(grep "command failed" < .ngrok.log)

if [[ -z "$HAS_ERRORS" ]]; then
  echo ""
  echo "-------------copy it-------------------"
  echo "$(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")"
  echo "---------------------------------------"
else
  echo "$HAS_ERRORS"
  exit 4
fi
