#!/bin/bash

# build near

apt update 
apt install -y wget  curl apt-utils 
apt upgrade -y 
apt install -y git  
apt install -y binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python  protobuf-compiler libssl-dev pkg-config clang llvm  
apt install -y python3-pip 
USER_BASE_BIN=$(python3 -m site --user-base)/bin 
export PATH="$USER_BASE_BIN:$PATH" 
cd 
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  -s -- -y
source "$HOME/.cargo/env"
wget https://github.com/near/nearcore/archive/refs/tags/1.29.0-rc.2.tar.gz 
tar -xvzf 1.29.0-rc.1.tar.gz 
cd nearcore-1.29.0-rc.1/ 
cargo build -p neard --release --features shardnet 
cp target/release/neard /usr/local/bin/neard 

cat <<EOF > /etc/systemd/system/neard.service
[Unit]
Description=NEARd Daemon Service

[Service]
Type=simple
User=root
WorkingDirectory=/root/.near
ExecStart=/usr/local/bin/neard run
StandardOutput=file:/root/.near/neard.log
StandardError=file:/root/.near/neard.err
Restart=on-failure
RestartSec=30
KillSignal=SIGINT
TimeoutStopSec=45
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF

# install near CLI

apt remove -y nodejs 
apt install -y  jq \
		curl \
		wget \
		awscli 
curl -sL https://deb.nodesource.com/setup_18.x |  bash - 
apt install -y nodejs 
        npm install -g near-cli 
npm install -g npm@8.19.1 
        export NEAR_ENV=testnet && echo 'export NEAR_ENV=testnet' >> ~/.bashrc 

# make near config 

/usr/local/bin/neard --home $HOME/.near init --chain-id testnet --download-genesis 
rm $HOME/.near/config.json 
wget -O $HOME/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/testnet/config.json 

# get database
aws s3 --no-sign-request cp s3://near-protocol-public/backups/testnet/rpc/latest . 
LATEST=$(cat latest) 
aws s3 --no-sign-request cp --no-sign-request --recursive s3://near-protocol-public/backups/testnet/rpc/$LATEST $HOME/.near/data

# start near
systemctl daemon-reload
systemctl enable --now neard.service
