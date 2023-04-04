# Run a Near validator


## edit env variable in docker-compose file 

Once sinced, here is how to run command on neard instance

```
docker exec -it  production-neard-1  bash
```

then run you commands for example: 

```
near login
```

or 

```
# update to new - it will take 4 epochs for the new keys to get slots (until then the old one  is active)
near call <POOL_ID>.poolv1.near update_staking_key '{"stake_public_key": "ed25519:Fcv...."}'   --accountId <OWNER_ACCOUNT>
```

about the migration procedure, note that moving validator_key is the fastest way.


## metrics

you need certificate files named `server.crt` and `server.key` in `/srv/tls/` to make your metrics accessible through https


