# Usage

## Near-cli 

```
docker run p2pstaking/near-cli:latest <CMD>
```

for example

```
docker run p2pstaking/near-cli:latest near proposals
```


## Neard

```
docker run p2pstaking/neard:latest \
  -v ~/.near/:/root/.near/ \
  -v ~/.near-credentials:/root/.near-credentials \ 
  -v ~/.near-config:/root/.near-config \
  -e NEAR_ENV=<mainnet,testnet> \
  -e POOL_ID=<your pool id> 
```
