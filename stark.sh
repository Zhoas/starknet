#!/bin/bash
sudo apt install git
sudo apt install curl
curl -s https://raw.githubusercontent.com/cryptongithub/init/main/logo.sh | bash && sleep 2 

echo "=+=+=+=+=+=++=+=++=crypton=+=+=+=+=+=++=+=++="
echo -e "\e[1m\e[32m ENTER_YOUR_ALCHEMY_HTTP_ADDRESS \e[0m"
read -p "YOUR_ALCHEMY_HTTP_ADDRESS : " ALCHEMY

echo 'export ALCHEMY='$ALCHEMY >> $HOME/.bash_profile


echo "=+=+=+=+=+=++=+=++=crypton=+=+=+=+=+=++=+=++="

sleep 2
sudo apt update -y && sudo apt install curl git tmux python3 python3-venv python3-dev build-essential libgmp-dev pkg-config libssl-dev -y
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustup update stable --force
cd $HOME
rm -rf pathfinder
git clone -b v0.1.6-alpha https://github.com/eqlabs/pathfinder.git
cd pathfinder/py
python3 -m venv .venv
source .venv/bin/activate
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt
pytest
cargo build --release --bin pathfinder
sleep 2
source $HOME/.bash_profile
mv ~/pathfinder/target/release/pathfinder /usr/local/bin/

echo "=+=+=+=+=+=++=+=++=crypton=+=+=+=+=+=++=+=++="
echo -e "\e[1m\e[32m Creating service... \e[0m"

echo "[Unit]
Description=StarkNet
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/pathfinder/py
ExecStart=/bin/bash -c \"source $HOME/pathfinder/py/.venv/bin/activate && /usr/local/bin/pathfinder --http-rpc=\"0.0.0.0:9545\" --ethereum.url $ALCHEMY\"
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/starknetd.service
mv $HOME/starknetd.service /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable starknetd
sudo systemctl restart starknetd
echo "==================================================="
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service starknetd status | grep active` =~ "running" ]]; then
  echo -e "Your StarkNet node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice starknetd status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your StarkNet node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
