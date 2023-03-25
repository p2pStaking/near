#!/bin/bash

near call ${MY_POOL_ID:-'p2pstaking.poolv1.near'} unstake "{\"amount\": \"$1\"}" --accountId $2 
