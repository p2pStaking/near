#!/bin/bash 

#  REQUIREMENTS
#### apt install -y jq httpie
#### ~/.telegram.env
[[ "" ==  "$(which http)" || "" == "$(which jq)" ]] && echo "jq  httpie required: apt install -y jq httpie"
[[ ! -f "$HOME/.telegram.env" ]] && echo "BOT_TOKEN=" > ~/.telegram.env && echo "CHANNEL_ID=" >> ~/.telegram.env && \
	echo "Edit telegram bot env file:  ~/.telegram.env "

RPC=$(jq -r .rpc.addr ~/.near/config.json)
VALIDATOR_ID=$(curl -s  $RPC/status | jq -r .validator_account_id)


# load saved data
source ~/.near_node_state > /dev/null 2>&1

# get current value
BLOCK_HEIGHT=$(http  $RPC jsonrpc=2.0 method=block params:='{"finality":"final"}' id=dontcare | jq .result.header.height)
MISSED_BLOCKS=$(http  $RPC jsonrpc=2.0 method=validators params:='[null]' id=dontcare |  jq -c ".result.current_validators[] | select(.account_id | contains (\"$VALIDATOR_ID\")) |  .num_expected_blocks - .num_produced_blocks")
MISSED_CHUNKS=$(http  $RPC jsonrpc=2.0 method=validators params:='[null]' id=dontcare \
	|  jq -c ".result.current_validators[] | select(.account_id | contains (\"$VALIDATOR_ID\")) |  .num_expected_chunks - .num_produced_chunks")

[[ "$1" == "--debug" ]] && \
	echo "BLOCK_HEIGHT=$BLOCK_HEIGHT" && \
	echo "LAST_BLOCK_HEIGHT=$LAST_BLOCK_HEIGHT" && \
	echo "MISSED_BLOCKS=$MISSED_BLOCKS" && \
        echo "LAST_MISSED_BLOCKS=$LAST_MISSED_BLOCKS" && \
        echo "MISSED_CHUNKS=$MISSED_CHUNKS" && \
        echo "LAST_MISSED_CHUNKS=$LAST_MISSED_CHUNKS" 

TELEGRAM_MESSAGE=$VALIDATOR_ID

# build telegram message
[[ "$LAST_BLOCK_HEIGHT" == "$BLOCK_HEIGHT" ]] && \
	TELEGRAM_MESSAGE="$TELEGRAM_MESSAGE 
   Node stuck on block $BLOCK_HEIGHT"

[[ "$LAST_MISSED_BLOCKS" -lt "$MISSED_BLOCKS" || "$LAST_MISSED_CHUNKS" -lt "$MISSED_CHUNKS" ]] && \
	JSON_SAMPLE=$(http  $RPC jsonrpc=2.0 method=validators params:='[null]' id=dontcare  | jq -c  ".result.current_validators[] | select(.account_id | contains (\"$VALIDATOR_ID\"))" | jq -r 'to_entries[] | "\(.key)=\(.value)"'   | tr -s "_" "-" ) && \
	TELEGRAM_MESSAGE="$TELEGRAM_MESSAGE 
  Validator missing chunk/block production: 
   $JSON_SAMPLE"


ACTIVE_PEERS=$(http  $RPC jsonrpc=2.0 method=network_info  params:='[null]' id=dontcare | jq .result.num_active_peers)
[[ "$ACTIVE_PEERS" -lt "3" ]] && \
	TELEGRAM_MESSAGE="$TELEGRAM_MESSAGE 
   Node low peer acrive: $ACTIVE_PEERS"

#save current values

cat <<EOF | tee ~/.near_node_state > /dev/null
LAST_BLOCK_HEIGHT=$BLOCK_HEIGHT
LAST_MISSED_BLOCKS=$MISSED_BLOCKS
LAST_MISSED_CHUNKS=$MISSED_CHUNKS
EOF

[[ "$1" == "--debug" ]] && \
	more ~/.near_node_state && \
	echo "telegram message: $TELEGRAM_MESSAGE"

[[ "$VALIDATOR_ID" != "$TELEGRAM_MESSAGE" ]] && \
	source ~/.telegram.env && \
	curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage -d chat_id=${CHANNEL_ID} -d parse_mode="Markdown" \
	--data-urlencode  text="Near Validator notification 
 $TELEGRAM_MESSAGE" 


