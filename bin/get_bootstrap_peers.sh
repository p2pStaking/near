#!/bin/bash 

RPC=https://free.rpc.fastnear.com
RPC=https://rpc.mainnet.near.org
#RPC=https://near.lava.build:443

curl -X POST $RPC \
  -H "Content-Type: application/json" \
  -d '{
        "jsonrpc": "2.0",
        "method": "network_info",
        "params": [],
        "id": "dontcare"
      }' | \
jq '.result.active_peers as $list1 | .result.known_producers as $list2 |
$list1[] as $active_peer | $list2[] |
select(.peer_id == $active_peer.id) |
"\(.peer_id)@\($active_peer.addr)"' |\
awk 'NR>2 {print ","} length($0) {print p} {p=$0}' ORS="" | sed 's/"//g'

