#!/bin/bash 

[[ -f config.json ]] && mv config.json config.$(date +%y%m%d%H%M).json
wget https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/mainnet/rpc/config.json


bin_dir="$( dirname "${BASH_SOURCE[0]}" )"
bootstrap_peers=$($bin_dir/get_bootstrap_peers.sh)
result=$(cat config.json | jq '.tracked_shards_config="NoShards"' | jq '.rpc.addr="0.0.0.0:9030"' | jq ".network.boot_nodes=\"$bootstrap_peers\"" )
echo $result | jq .  > config.json
