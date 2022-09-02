#!/bin/bash 

[ ! -f "$HOME/.near/config.json" ] && \
        /usr/local/bin/neard --home $HOME/.near init --chain-id testnet --download-genesis && \
        rm $HOME/.near/config.json && \
        wget -O $HOME/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/testnet/config.json && \
	aws s3 --no-sign-request cp s3://near-protocol-public/backups/testnet/rpc/latest . && \
	LATEST=$(cat latest) && \
	aws s3 --no-sign-request cp --no-sign-request --recursive s3://near-protocol-public/backups/testnet/rpc/$LATEST $HOME/.near/data

/usr/local/bin/neard --home $HOME/.near run
