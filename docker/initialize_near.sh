#!/bin/bash 

if [ ! -f  ~/.near/genesis.json ] ; then 
	STAKING_POOL_ID=${POOL_ID}.poolv1.near
	mkdir -p  ~/.near
	cd ~/.near
	/usr/local/bin/neard init --chain-id="$NEAR_ENV"  --account-id="$STAKING_POOL_ID" --download-config 
	near generate-key ${POOL_ID}
fi



