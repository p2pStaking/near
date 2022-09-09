Installation video in French: https://www.youtube.com/watch?v=6RWrySMS__s&t=231s

# Run a testnet validator chunk only on Akash network

## Approach 

At the time of writing,  there is an active known issue for Akash deployment with persistent storage.  The issue involves the inability to update a deployment when persistent storage is in use.  The issue is currently in the hands of Akash engineering awaiting resolution.

Unfortunately - until the issue is resolved - it is not possible to update a persistent storage enabled workload.  And it would be necessary to close the pre-existing deployment and launch anew with the updated image.  

In other words, we cannot update our docker image when there is a near update or if we need to restart our validator. Otherwise, we will have to download database from scratch and go through configuration tasks again.

So, our strategy is to deploy a docker image supporting SSH connection and Systemd once on Akash. Then we can manage and administer the instance like any VM or  physical server. We can build near binaries, restart services from there (with no need to update the image).

## Deploy p2pstaking/akash:ubuntu-focal-ssh-systemd image

We explain here how to deploy our ubuntu image which comes with sshd and supports for systemctl commands.  (except journalctl not working yet)
From there, you will able to deploy most services...

### Install Cloudmos

See [official docs](https://docs.akash.network/guides/deploy)

### Create a wallet 
- Choose `ÀDD ACCOUNT` add backp your mnemonic

Add funds 
- Copy your wallet address and funds to it
- Once arrived, clic `CREATE CERTIFICATE`on the right of the app
- Click `APPROVE`

### Deploy using Cloudmos
- click `DEPLOY`

<img src="https://user-images.githubusercontent.com/110183218/188599736-f4eb1633-077a-4020-bc56-5c9d207cec62.png" width="750" >

- Choose to deploy an `Empty` file 
<img src="https://user-images.githubusercontent.com/110183218/188599891-fe3d7816-b468-4e4f-838a-b40cb0f25db2.png" width="750" >

- Copy and past the content of our [deploy.yml](https://raw.githubusercontent.com/p2pStaking/near/main/stake-wars/challenge17/deploy.yml)

- Edit `MY_IDENTITY` variable and set your ssh certificate public key

<img src="https://user-images.githubusercontent.com/110183218/188600399-62c1d267-b1ea-4708-8d57-5e6a783d23dd.png" width="750" >

- Clic `CREATE DEPLOYMENT` 

- Adjust your deposit amount (5 $AKT is enough for a simple test)

<img src="https://user-images.githubusercontent.com/110183218/188600683-5bc3ea04-8171-4ce2-9b39-e2a630404c55.png" width="300" >

- Click `DEPOSIT` and `APPROVE` on the next popup

<img src="https://user-images.githubusercontent.com/110183218/188600835-4ae6fe70-ee34-49df-840f-27fc874fcdc6.png" width="300" >


- Wait 1 minute until bids arrive... And pick the best one. Note that storage class is important (beta1=HDD, beta2=SSD, beta3=NVMe)

<img src="https://user-images.githubusercontent.com/110183218/188601036-2ca4d139-d82c-4471-becb-7d9339b614bc.png" width="750" >


- Click `ACCEPT BID` and `APPROVE`

<img src="https://user-images.githubusercontent.com/110183218/188601558-bfa08922-6e00-4dbd-8a14-178e7e96f859.png" width="750" >

- Wait for the transaction confirmation and the deployment 

<img src="https://user-images.githubusercontent.com/110183218/188601763-fb17c737-4298-4cd4-93b4-455f229788e1.png" width="300" >

<img src="https://user-images.githubusercontent.com/110183218/188602828-7440c053-32a0-4220-b1f2-5b344c0d2bdd.png" width="750" >

### Connect to your container with ssh

- Go to `Deployments/LEASES` 
- Clic to the forwarded port ending with `:22`
<img src="https://user-images.githubusercontent.com/110183218/188680811-8c688912-4fa2-43bb-a42d-8fafae882d0b.png" width="750" >
- It will open an unreachable URL in your browser, copy  it and use the domain name and port to connect with SSH
<img src="https://user-images.githubusercontent.com/110183218/188681853-5d6c6218-36a6-477f-8171-635d9f0d5f7c.png" width="750">

- Connect using an SSH client. On Linux: 

```
ssh -i ~/.ssh/<ID_ED22519_FILE> -p <PORT> root@<DOMAIN>
```
(following our example) `ssh -i ~/.ssh/id_ed22519 -p 37667 root@rider.pots.com`

Now you're set to install about anything....

## Install a node (chunk only build for testnet)

It will take some time, espacially the database download, better to use screen 

```
screen
```

```
curl -sL https://raw.githubusercontent.com/p2pStaking/near/main/stake-wars/challenge17/install_near_testnet_chunk_only.sh  | bash - | tee -a /root/.near/neard.err
```

Your can detach `Ctrl a d` and attach `screen -r` later. 

Once synced you can following this guide to start a validator. 

## Configure validator (testnet)

The following steps will create validator key and the staking pool.

- Create an [wallet](https://wallet.testnet.near.org/) 
- Authorize login
```
near login
```
- Create validator key
```
OWNER_ID=<YOUR_WALLET>
POOL_NAME=<YOUR_POOL_NAME>
POOL_ID=$POOL_NAME.pool.f863973.m0
near generate-key $POOL_ID
cp ~/.near-credentials/testnet/$POOL_ID.json ~/.near/validator_key.json
sed -i "s/private_key/secret_key/" ~/.near/validator_key.json 
```
** backup your validator key `~/.near/validator_key.json` ** 
- Create your staking pool
```
PUBLIC_KEY=$(jq -r .public_key ~/.near/validator_key.json)
```
```
near call pool.f863973.m0  create_staking_pool "{\"staking_pool_id\": \"$POOL_NAME\", \"owner_id\": \"$OWNER_ID\", \"stake_public_key\": \"$PUBLIC_KEY\", \"reward_fee_fraction\": {\"numerator\": 5, \"denominator\": 100}, \"code_hash\":\"DD428g9eqLL8fWUxv8QSpVFzyHi1Qd16P8ephYCTmMSZ\"}" --accountId="$OWNER_ID" --amount=30 --gas=300000000000000
```
when succeed you will see `true` in the output.

Basic interactions with your contract

Stake some NEARs
```
near call $POOL_ID deposit_and_stake --amount 111 --accountId $OWNER_ID --gas=300000000000000
```

Ping your pool

```
near call $POOL_ID ping '{}' --accountId $OWNER_ID --gas=300000000000000
```

### Optionally clone and build this projet 

```
git clone https://github.com/p2pStaking/near.git
cd near/stake-wars/challenge17
docker build -t akash:ubuntu-focal-ssh-systemd-version
docker image tag akash:ubuntu-focal-ssh-systemd-version your_repo/akash:ubuntu-focal-ssh-systemd-version
```

