#!/bin/bash

if  [ ! -f "~/.near/validator_key.json" ] ; then
	/root/initialize_near.sh
	/root/get_snapshot.sh 
fi

/root/nearcore/target/release/neard run
