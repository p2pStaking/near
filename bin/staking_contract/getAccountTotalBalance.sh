#!/bin/bash

near view ${MY_POOL_ID:-'p2pstaking.poolv1.near'} get_account_total_balance "{\"account_id\": \"$1\"}"
