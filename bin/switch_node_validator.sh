#!/bin/bash
#
[[ "$1" == "" ]] && echo " usage : $0 TARGET " \
	&& echo "TARGET: validator or node" \
	&& exit 1 



key_dir=node
[[ "$1" == "validator" ]] && key_dir=validator

[[ -d ~/$key_dir ]] || { echo "missing key dir : ~/$key_dir "; exit 1 ; }
[[ -d ~/$key_dir/.near ]] || { echo "missing key dir : ~/$key_dir/.near "; exit 1 ; }
[[ -d ~/$key_dir/.near-credentials/mainnet ]] || { echo "missing key dir : ~/$key_dir/.near-credentials/mainnet "; exit 1 ; }

rm  ~/.near-credentials/mainnet/* # sec validator to node
cp ~/$key_dir/.near/* ~/.near/
cp ~/$key_dir/.near-credentials/mainnet/* ~/.near-credentials/mainnet/


echo "double check time: no diff should appear here ...."

diff ~/$key_dir/.near/node_key.json ~/.near/node_key.json
diff ~/$key_dir/.near/validator_key.json ~/.near/validator_key.json
diff ~/$key_dir/.near-credentials/mainnet/p2pstaking.near.json ~/.near-credentials/mainnet/p2pstaking.near.json
diff ~/$key_dir/.near-credentials/mainnet/p2pstaking.json ~/.near-credentials/mainnet/p2pstaking.json

echo 'Done!'

