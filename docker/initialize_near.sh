#!/bin/bash 

if [ ! -f "/.near/genesis.json" ] ; then 
	read -p 'POOL_ID  (ex: xx for the following staking pool id $POOL_ID.poolv1.near)' POOL_ID
	STAKING_POOL_ID=${POOL_ID}.poolv1.near
	mkdir ~/.near
	cd ~/.near
	/root/nearcore/target/release/neard init --chain-id="$NEAR_ENV"  --account-id="$STAKING_POOL_ID" 
	rm /root/.near/config.json /root/.near/genesis.json
	wget -c https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/${NEAR_ENV}/config.json
	wget -c https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/${NEAR_ENV}/genesis.json
	near generate-key ${POOL_ID}
fi



