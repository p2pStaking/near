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
NEAR_RELEASE_VERSION=1.30.0 #version to build
```

```
docker build  . -t p2pstaking/neard:$NEAR_RELEASE_VERSION  --build-arg NEAR_RELEASE_VERSION="$NEAR_RELEASE_VERSION"
docker push p2pstaking/neard:$NEAR_RELEASE_VERSION
```

### run

```
docker run p2pstaking/neard:latest \
  -v ~/.near/:/root/.near/ \
  -v ~/.near-credentials:/root/.near-credentials \ 
  -v ~/.near-config:/root/.near-config \
  -e NEAR_ENV=<mainnet,testnet> \
  -e POOL_ID=<your pool id> 
```
