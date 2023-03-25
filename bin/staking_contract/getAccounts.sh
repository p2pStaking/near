#!/bin/bash

near view ${MY_POOL_ID:-'p2pstaking.poolv1.near'} get_accounts '{"from_index": 0, "limit": 99999}'
