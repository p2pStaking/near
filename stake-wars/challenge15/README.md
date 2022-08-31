# Setup a kuutamo High Availability (HA) NEAR Validator on localnet

Here we follow this [guide](https://github.com/kuutamolabs/kuutamod/blob/main/docs/run-localnet.md) except that we will install dependencies manually

We use a debian/bullseye image. If you're not the root user prefix most command with sudo.

```
apt install -y git curl 
```

install rust

```
apt install -y clang build-essential make
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

## Requirements

(each version check should output the binary version, if it doesn't make it works before continuing)

install consul 

```
wget https://releases.hashicorp.com/consul/1.13.1/consul_1.13.1_linux_amd64.zip
unzip consul_1.13.1_linux_amd64.zip
mv consul /usr/local/bin/
consul --version
```

install hivemind

```
wget https://github.com/DarthSim/hivemind/releases/download/v1.1.0/hivemind-v1.1.0-linux-amd64.gz
gzip -d hivemind-v1.1.0-linux-amd64.gz 
chmod +x hivemind-v1.1.0-linux-amd64 
cp hivemind-v1.1.0-linux-amd64 /usr/local/bin/hivemind
./hivemind --version
```


install neard 

```
git clone https://github.com/near/nearcore
cd nearcore
git fetch
git checkout <VERSION>
```

For shardnet get <VERSION> [here](https://github.com/near/stakewars-iii/blob/main/commit.md)
  
```
cargo build -p neard --release --features shardnet
cp target/release/neard /usr/local/bin/
neard --version
```
  
install kuutamod 
  
```
git clone https://github.com/kuutamolabs/kuutamod
cd kuutamod
cargo build
./target/debug/kuutamod --version
```
 
  
## Running localnet setup
  
```
hivemind
```

hivemind starts consul, sets up the localnet configuration and starts three neard nodes for this network.

  ![hivemind](https://user-images.githubusercontent.com/110183218/187706474-46fc9d9d-fd4a-488c-9f19-b6cac14b5ca9.jpg)
  
  The scripts also set up keys and configuration for two kuutamod instances. The localnet configuration for all nodes is stored in `.data/near/localnet`
  
  ![image](https://user-images.githubusercontent.com/110183218/187708527-c16fce9e-8442-40d1-8793-f2d82358f371.png)

  Let's start one kuutamod instance: 
  
  ```
  ./target/debug/kuutamod --neard-home .data/near/localnet/kuutamod0/ \
  --voter-node-key .data/near/localnet/kuutamod0/voter_node_key.json \
  --validator-node-key .data/near/localnet/node3/node_key.json \
  --validator-key .data/near/localnet/node3/validator_key.json \
  --near-boot-nodes $(jq -r .public_key < .data/near/localnet/node0/node_key.json)@127.0.0.1:33301
```

We can see it starts as a validator
                                                                                                  
![image](https://user-images.githubusercontent.com/110183218/187710052-67d2a795-d8a3-46b8-ae25-70049e7baf53.png)
                                                                                                  
and we can double check using it exporter
                                                                                                  
![image](https://user-images.githubusercontent.com/110183218/187710371-8dba5241-457d-49c4-94b4-d8057eeba5f3.png)
                                                                                                  
also configuration is linked to validator's key 
    
![image](https://user-images.githubusercontent.com/110183218/187711119-8291a7b0-9a81-4f04-a824-8b3a9c5a0f43.png)
    
 Next, we start the other kuutamod instance
    
 ```
  ./target/debug/kuutamod \
  --exporter-address 127.0.0.1:2234 \
  --validator-network-addr 0.0.0.0:24569 \
  --voter-network-addr 0.0.0.0:24570 \
  --neard-home .data/near/localnet/kuutamod1/ \
  --voter-node-key .data/near/localnet/kuutamod1/voter_node_key.json \
  --validator-node-key .data/near/localnet/node3/node_key.json \
  --validator-key .data/near/localnet/node3/validator_key.json \
  --near-boot-nodes $(jq -r .public_key < .data/near/localnet/node0/node_key.json)@127.0.0.1:33301  
  ```

This time it starts as a full node 
    
![image](https://user-images.githubusercontent.com/110183218/187711750-d38e4d71-8eab-4c48-acbf-fd581c23b224.png)

    
same double checks here (note we are using another exporter port): 
    
![image](https://user-images.githubusercontent.com/110183218/187712537-9502d25c-0d2f-4007-8d7d-0fd3c4a0a245.png)

![image](https://user-images.githubusercontent.com/110183218/187712647-1c10befe-ff6f-4ae1-9c5a-2cd9afcf5148.png)

    
Finally let's kill (Ctrl C) kuutamod0 and see what happens
                                                                                                  
on kuutamod0: 

![image](https://user-images.githubusercontent.com/110183218/187713609-e3106bdc-37f6-44ef-b037-faa1b3ae0311.png)


                                                                                                  
at the same time on kuutamod1

![image](https://user-images.githubusercontent.com/110183218/187713386-600f243a-589c-47fd-b790-422b48a68083.png)

let's double check that kuutamod1 is now a validator
    
![image](https://user-images.githubusercontent.com/110183218/187714045-83f52913-718c-48f8-b08a-df58178b4a2a.png)


It worked!!!
