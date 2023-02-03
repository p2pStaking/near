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

### build 

```
NEAR_RELEASE_VERSION=<x.x.x>
```

```
docker build  . -t p2pstaking/neard:$NEAR_RELEASE_VERSION  --build-arg NEAR_RELEASE_VERSION="$NEAR_RELEASE_VERSION"
docker push p2pstaking/neard:$NEAR_RELEASE_VERSION
```

### run

```
docker \
  -v ~/.near/:/root/.near/ \
  -v ~/.near-credentials:/root/.near-credentials \ 
  -v ~/.near-config:/root/.near-config \
  -e NEAR_ENV=<mainnet,testnet> \
  -e POOL_ID=<your pool id> \
	p2pstaking/neard:latest
```
