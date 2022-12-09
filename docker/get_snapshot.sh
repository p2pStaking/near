#!/bin/bash

#read -p "it will take a while, consider using screen. You are going to remove ~/.near/data directory (y/n)  " CONFIRM
#[[ "$CONFIRM" == "y" ]] || exit 

if [ ! -d  ~/.near/data ] ; then

	mkdir  ~/.near/data
	apt-get install awscli -y
	aws s3 --no-sign-request cp s3://near-protocol-public/backups/${NEAR_ENV}/rpc/latest .
	LATEST=$(cat latest)
	aws s3 --no-sign-request cp --no-sign-request --recursive s3://near-protocol-public/backups/${NEAR_ENV}/rpc/$LATEST ~/.near/data

fi
