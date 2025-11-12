#!/bin/bash

## Near  exporter for a prometheus through pushgateway
# requirements : jq, near cli , curl 

[[ -z "$VALIDATOR_NAME" ]] && echo "you must set VALIDATOR_NAME " && exit 0
[[ -z "$NEAR_ENV" ]] && echo "you must set NEAR_ENV " && exit 0

PUSHGATEWAY_URL=${PUSHGATEWAY_URL:-"http://localhost:9091"}
NEAR_METRIC_PORT=${NEAR_METRIC_PORT:-"3030"}


while :; do
    case $1 in
        -h|-\?|--help)
            echo "export near metrics to pushgateway (--help : help msg | --debug : only print exported values)"    # Display a usage synopsis.
            exit
            ;;
        --debug)
            debug="1"
            ;;
        -?*)
            echo 'Error: Unknown option (aborded): %s\n' "$1" >&2
            exit 
            ;;
        *)              
            break
            ;;
   esac
   shift 
done

tmp_status=$(mktemp)
trap "rm $tmp_status" EXIT
tmp_status_next=$(mktemp)
trap "rm $tmp_status_next" EXIT
tmp_status_validator=$(mktemp)
trap "rm $tmp_status_validator" EXIT

/usr/local/bin/near validators current &> $tmp_status
/usr/local/bin/near validators next &> $tmp_status_next
curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' \
        -H 'Content-Type: application/json' \
        http://localhost:$NEAR_METRIC_PORT | jq ".result.current_validators[]  | select(.account_id |  startswith(\"$VALIDATOR_NAME\"))" &> $tmp_status_validator


tmp_metrics=$(mktemp)
trap "rm $tmp_metrics" EXIT

near_validator_next=1
grep -q $VALIDATOR_NAME $tmp_status_next  || near_validator_next=0
grep $VALIDATOR_NAME $tmp_status_next | grep -q 'Kicked out' && near_validator_next=0

grep_amount="[0-9]{0,},{0,1}[0-9]{1,},{0,1}[0-9]{0,}"

# getting node's numbers
node=$(grep "$VALIDATOR_NAME" $tmp_status )

near_stake=$(echo $node  |  sed -r 's/.* ([0-9]+),([0-9]+).*/\1\2/g')
near_uptime=$(echo $node  | sed -r 's/.* ([0-9]+\.?[0-9]{0,})\%.*/\1/g' )
echo "$near_uptime" | grep -q "NaN" && near_uptime=100
near_blocks_produced=$(jq .num_produced_blocks $tmp_status_validator)
near_blocks_expected=$(jq .num_expected_blocks $tmp_status_validator)
near_chunks_produced=$(jq .num_produced_chunks $tmp_status_validator)
near_chunks_expected=$(jq .num_expected_chunks $tmp_status_validator)
near_validator_account_total_balance=$(near view $VALIDATOR_NAME get_total_staked_balance "{}" | grep -v 'View call'  | sed "s/'//g")
near_validator_stake_total_balance=$(near view $VALIDATOR_NAME get_account_total_balance "{\"account_id\": \"${POOL_ID}.near\"}" | grep -v 'View call'  | sed "s/'//g")
near_validator_stake_delegators_count=$(/usr/local/bin/staking_contract/getAccounts.sh| grep account_id | wc -l)

URL=$PUSHGATEWAY_URL/metrics/job/near/instance/$VALIDATOR_NAME

cat <<EOF >> $tmp_metrics
# TYPE near_seat_price gauge
near_seat_price $(grep 'seat price' $tmp_status  |   grep 'seat price:' | sed -r 's/.*seat price: ([0-9]+),([0-9]+).*/\1\2/g')
# TYPE near_stake gauge
near_stake ${near_stake:-0}
# TYPE near_uptime gauge
near_uptime ${near_uptime:-0}
# TYPE near_blocks_produced gauge
near_blocks_produced ${near_blocks_produced:-0}
# TYPE near_blocks_expected gauge
near_blocks_expected ${near_blocks_expected:-0}
# TYPE near_validator_next gauge
near_validator_next $near_validator_next
# TYPE near_chunks_produced gauge
near_chunks_produced ${near_chunks_produced:-0}
# TYPE near_chunks_expected gauge
near_chunks_expected ${near_chunks_expected:-0}
# TYPE near_validator_account_total_balance gauge
near_validator_account_total_balance{name="$VALIDATOR_NAME"} ${near_validator_account_total_balance:-0}
# TYPE near_validator_stake_total_balance gauge
near_validator_stake_total_balance{name="$VALIDATOR_NAME"} ${near_validator_stake_total_balance:-0}
# TYPE near_validator_stake_delegators_count gauge
near_validator_stake_delegators_count{name="$VALIDATOR_NAME"} ${near_validator_stake_delegators_count:-0}
EOF

if [[ $debug -eq 1 ]] 
        then 
		echo "VALIDATOR_NAME: $VALIDATOR_NAME, infos: "
		echo "$node"
		echo ""
		echo "URL: $URL"
                cat $tmp_metrics
                exit
fi


cat $tmp_metrics  |  curl --insecure -s --data-binary @-  $URL

# TODO : remove once migration done (backward compatibility push to host pgw instance)
curl   localhost:9091 2>&1 | grep -q 'Connection refused' || \
cat $tmp_metrics  |  curl --insecure -s --data-binary @-  https://127.0.0.1:9091/metrics/job/near/instance/$VALIDATOR_NAME

