#!/bin/bash 

[ ! -f "$HOME/.near/config.json" ] && \
        /usr/local/bin/neard --home $HOME/.near init --chain-id shardnet --download-genesis && \
        rm $HOME/.near/config.json && \
        wget -O $HOME/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/config.json

/usr/local/bin/neard --home $HOME/.near run
