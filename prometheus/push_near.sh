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




tmp_validators=$(mktemp)
tmp_status_validator=$(mktemp)
tmp_metrics=$(mktemp)
trap "rm -f $tmp_validators $tmp_status_validator $tmp_metrics" EXIT

curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' \
        -H 'Content-Type: application/json' \
        http://localhost:$NEAR_METRIC_PORT > $tmp_validators

jq ".result.current_validators[] | select(.account_id == \"$VALIDATOR_NAME\")" $tmp_validators > $tmp_status_validator

# présent dans le set du prochain epoch, et pas dans la liste des kick-out
near_validator_next=$(jq "[.result.next_validators[].account_id] | index(\"$VALIDATOR_NAME\") != null" $tmp_validators | grep -q true && echo 1 || echo 0)
jq -e ".result.prev_epoch_kickout[]? | select(.account_id == \"$VALIDATOR_NAME\")" $tmp_validators > /dev/null && near_validator_next=0

# stake en NEAR entiers (yoctoNEAR -> on tronque 24 chiffres)
near_stake=$(jq -r '.stake[:-24] // "0"' $tmp_status_validator)

near_blocks_produced=$(jq .num_produced_blocks $tmp_status_validator)
near_blocks_expected=$(jq .num_expected_blocks $tmp_status_validator)
near_chunks_produced=$(jq .num_produced_chunks $tmp_status_validator)
near_chunks_expected=$(jq .num_expected_chunks $tmp_status_validator)
near_endorsements_produced=$(jq .num_produced_endorsements $tmp_status_validator)
near_endorsements_expected=$(jq .num_expected_endorsements $tmp_status_validator)

# uptime : ratio global produits / attendus, 100 si rien d'attendu (début d'epoch)
near_uptime=$(jq -r '
  (.num_expected_blocks + .num_expected_chunks + .num_expected_endorsements) as $exp
  | if $exp == 0 then 100
    else ((.num_produced_blocks + .num_produced_chunks + .num_produced_endorsements) / $exp * 10000 | floor) / 100
    end' $tmp_status_validator)

near_validator_account_total_balance=$(near view $VALIDATOR_NAME get_total_staked_balance "{}" | grep -v 'View call'  | sed "s/'//g")
near_validator_stake_total_balance=$(near view $VALIDATOR_NAME get_account_total_balance "{\"account_id\": \"${POOL_ID}.near\"}" | grep -v 'View call'  | sed "s/'//g")
near_validator_stake_delegators_count=$(/usr/local/bin/staking_contract/getAccounts.sh| grep account_id | wc -l)
near_seat_price=$(jq -r '[.result.current_validators[].stake | .[:-24] | tonumber] | min' $tmp_validators)
near_p2pstaking_near_staked=$(/usr/local/bin/near view \
  p2pstaking.poolv1.near get_account \
  '{"account_id":"p2pstaking.near"}' \
  --networkId mainnet \
| sed -n '/^{/,/^}/p' \
| sed -E "s/^([[:space:]]*)([[:alnum:]_]+):/\1\"\2\":/; s/'/\"/g" \
| jq -r  .staked_balance )
URL=$PUSHGATEWAY_URL/metrics/job/near/instance/$VALIDATOR_NAME

cat <<EOF >> $tmp_metrics
# TYPE near_seat_price gauge
near_seat_price ${near_seat_price:-0}
# TYPE near_p2pstaking_near_staked gauge
near_p2pstaking_near_staked ${near_p2pstaking_near_staked:-0}
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
