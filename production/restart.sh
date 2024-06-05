#!/bin/bash 

cd "$( dirname "${BASH_SOURCE[0]}" )"

docker pull p2pstaking/neard:latest

apt update
apt upgrade -y 


docker compose down 
docker compose up -d
docker logs -f production-neard-1
