#  Build docker image 

Here is the way to build and run a neard docker image by yourself. 
If you don't need to apply modification, feel free to use images directly from our repository:

```
docker run -d p2pstaking/near-node:testnet_chunk_only-last
```

## Testnet (Chunk only)

If needed, you can edit `Dockerfile-testnet_chunk_only` to build another version. 

(For example: clone near git repo and change the build command if you don't want to run a chunk only validator.)

```
git clone https://github.com/p2pStaking/near.git
cd near/docker/
docker build -f Dockerfile-testnet_chunk_only -t near-node:testnet_chunk_only-latest .
```


Then you can run it with

```
docker run -d near-node:testnet-last_chunk_only
```

# Deploy on Akash

Let's keep things simple here, we will use Cloudmos client and p2pstaking/near-node docker image. (advanced users should prefer to build their image, to deploy it to their own repository, and use Akash command line client) 


` install Cloudmos ` (see [Akash docs](https://docs.akash.network/guides/deploy/cloudmos-deploy-installation) )

` create a wallet and fund it ` (make sure to save and back up your credentials) 
You will need at least 10 $AKT to experiment with Akash.
AKT are Akash tokens used to pay fees on the network. Any deployment requires to lock up 5 $AKT.

(if you want to run a node on Akash, I suggest to buy enough $AKT to pay provider fees for at least 15 days)

` create a certificat `

Go to deployment and use `https://github.com/p2pStaking/near/blob/main/docker/run_near-testnet.sh`


`Deploy`

That's it. 
You can now use Cloudmos to view logs and run commands using its  Shell.
