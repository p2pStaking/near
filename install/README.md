# Présentation

Dans le cadre du programme 'Stake Wars: Episode', cette documentation indique comment configurer un validateur Near sur le réseau `shardnet`. 

# Choix du datacenter

## Pré requis
- CPU: 4 core CPU avec AVX support
- 8GB DDR
- 500 GB SSD

Utiliser un serveur ayant au minimum cette configuration. 

Ce guide d'installation concerne des serveurs linux, il a été testé sur `debian bullseye` et `ubuntu 20.04`. 

Un tel serveur dédié se loue pour moins de $80 chez OVH et sans doute moins de $60 chez Ikoula ou Hetzner. 

Bien qu'en dehors du périmètre de cette documentation, soyez miticuleux sur la sécurité de votre serveur. Notamment, veiller à:
- utiliser une authentification par clé SSH (et interdire les connexions SSH par mot de passe)
- renforcer la sécurité de votre serveur (https://www.informaticar.net/security-hardening-ubuntu-20-04/)

Pour la suite de cette documentation, nous supposerons que vous êtes connectés via SSH à votre serveur. 

# Installer et configurer un validateur NEAR

## Installer NEAR-CLI 

NEAR-CLI est une interface en ligne de commande qui permet d'interagir avec la blockchain Near.

```
sudo apt update && sudo apt upgrade -y
sudo apt remove  -y nodejs
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -  
sudo apt install -y nodejs
sudo apt install -y build-essential nodejs
PATH="$PATH"
```

S'assurer que `nodejs` et `npm` sont installés correctement

```
node -v
npm -v
```

Les versions suivantes doivent s'afficher: `v18.x.x` et `8.x.x`. 
Si ce n'est pas le cas, corriger le problème (pour ceci, google est votre ami)

Installer NEAR-CLI et définir `shardnet` comme environnement par défaut
```
sudo npm install -g near-cli
export NEAR_ENV=shardnet
echo 'export NEAR_ENV=shardnet' >> ~/.bashrc
```

## Installer un full node 

Vérifier que le serveur remplit les prérequis: 
```
lscpu | grep -P '(?=.*avx )(?=.*sse4.2 )(?=.*cx16 )(?=.*popcnt )' > /dev/null \
  && echo "Supported" \
  || echo "Not supported"
```

Installation et configuration des outils de développement

```
sudo apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python docker.io protobuf-compiler libssl-dev pkg-config clang llvm cargo
sudo apt install -y python3-pip
USER_BASE_BIN=$(python3 -m site --user-base)/bin
export PATH="$USER_BASE_BIN:$PATH"
sudo apt install -y clang build-essential make
```

Pour l'installation de `cargo`
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

 valider l'option 1 par défault avec la touche `Entrer`
 
```
source $HOME/.cargo/env
cd
git clone https://github.com/near/nearcore
cd nearcore
git fetch
```

Checkout le commit actuel. Disponible [ici](https://github.com/near/stakewars-iii/blob/main/commit.md)  pour le sharnet (voir discord pour les autres réseaux)

```
https://github.com/near/stakewars-iii/blob/main/commit.md
```

```
git checkout <version>
```

Compiler les sources (ça peut prendre un peu de temps)
```
cargo build -p neard --release --features shardnet
```

Préparer l'environnement (crée le répertoire `~/.near`) et télécharger la dernière snapshot
```
./target/release/neard --home ~/.near init --chain-id shardnet --download-genesis
rm ~/.near/config.json
wget -O ~/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/config.json
```


Installer le service neard 


```
cat <<EOF | sudo tee /etc/systemd/system/neard.service
[Unit]
Description=NEARd Daemon Service

[Service]
Type=simple
User=$(whoami)
#Group=near
WorkingDirectory=$(echo $HOME)/.near
ExecStart=$(echo $HOME)/nearcore/target/release/neard run
Restart=on-failure
RestartSec=30
KillSignal=SIGINT
TimeoutStopSec=45
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF
```

Lancer le node et le laisser se synchoniser

```
sudo systemctl daemon-reload
sudo systemctl enable --now neard
sudo journalctl -u neard -f 
```

Suivre les logs le temps de s'assurer que le noeud se connecte puis télécharge les premiers headers puis blocks. 
Quitter les logs avec `Ctrl C` (le noeud va continuer de se synchoniser)

## Configuration du validateur

Créer un compte sur [MyNearWallet](https://wallet.shardnet.near.org/). 
L'interface parle d'elle même. Dans le cas d'utilisation d'une passphrase, veiller à la sécuriser et ne jamais la partager.

S'assurer de disposer de tokens Near.

### Authoriser la connexion du serveur à ce compte

```
near login
```

![output](https://github.com/near/stakewars-iii/blob/main/challenges/images/1.png)

Copier l'URL dans le navigateur connecté à votre compte. Puis authoriser l'access. 

Le navigateur va afficher une page d'erreur mais NEAR-CLI doit afficher `Logged in as ********* successfully`
![output](https://github.com/near/stakewars-iii/raw/main/challenges/images/5.png)

### Créer le validateur 

```
near generate-key <pool_id>
```

`<pool_id>` est l'identifiant du pool tel qu'il sera affiché aux délégateurs. 
Sur le shardnet, il est de la forme `POOL_NAME.factory.shardnet.near` où `POOL_NAME` représente votre entité.

Copier le ficher créé

```
cp ~/.near-credentials/shardnet/POOL_NAME.json ~/.near/validator_key.json
```

Editer `~/.near/validator_key.json` : 
- remplacer `private_key` par `secret_key`
- associer à `account_id` la valeur `POOL_NAME.factory.shardnet.near` 

Redémarrer le noeud en validateur 

```
sudo systemctl restart neard
```

Pour assurer la sécurité des fonds, NEAR crée les staking pools via un factory smart contract.

Déployer une stakking pool: 

```
near call factory.shardnet.near create_staking_pool '{"staking_pool_id": "<pool id>", "owner_id": "<accountId>", "stake_public_key": "<public key>", "reward_fee_fraction": {"numerator": <fee>, "denominator": 100}, "code_hash":"DD428g9eqLL8fWUxv8QSpVFzyHi1Qd16P8ephYCTmMSZ"}' --accountId="<accountId>" --amount=30 --gas=300000000000000
```

- `<accountId>` est le nom du compte crée sur MyNearWallet
- `<public key>` est indiqué dans `~/.near/validator_key.json`
- `<fee>` est le frais du staking pool (5 pour 5%)
- `<pool id>` est l'identifiant généré ci-dessous (de la forme POOL_NAME.factory.shardnet.near)

Une fois le call exécuté, le message de sortie doit mentionner `True` pour indiquer que le pool est créé.

Il est maintenant possible de déposer et staker 
```
near call <pool_id> deposit_and_stake --amount <amount> --accountId <accountId> --gas=300000000000000
```
- `<amount>` montant de near tokens

La commande ping envoie une nouvelle proposition et met à jour la balance. Elle doit être réalisé à chaque époque. 

`near call <pool_id> ping '{}' --accountId <accountId> --gas=300000000000000`

il est judicieux de l'exécuter régulièrement avec CRON (`crontab -e`)

### Activation

Afin d'intégrer les validateurs actifs, il faut 
- que le noeud soit synchronisé
- avoir atteint le seat price (en délégations)
- avoir soumis une proposition via un ping
- produire plus de 90% des blocks assignés une fois actif

### Monitoring

Maintenant que le validateur est deployé, il est important de le surveiller. Voici les commandes principales afin d'effectuer le monitoring du validateur.

Nous avons besoin de `curl` et `jq`

```
sudo apt install -y curl jq
```

Commandes les plus importantes 
- status du noeud  `curl -s http://127.0.0.1:3030/status | jq .version` 
- validateurs actifs `near validators current`
- validateurs de l'époque suivante: `near validators next`
- validateurs demandant à intégrer l'active set: `near proposals`
- logs: `sudo journalctl -u near -f`
- delegations et stake: `near view <pool_id>.factory.shardnet.near get_accounts '{"from_index": 0, "limit": 10}' --accountId <accountId>.shardnet.near`
- raison de l'expulsion de l'active set: `curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' 127.0.0.1:3030 | jq -c '.result.prev_epoch_kickout[] | select(.account_id | contains ("<pool_id>"))' | jq .reason`
- blocks et chunks produits `curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' 127.0.0.1:3030 | jq -c '.result.prev_epoch_kickout[] | select(.account_id | contains ("<pool_id>"))' | jq .reason`

# Autres network (Mainnet, testnet, guildnet)

Les mêmes étapes s'appliquent pour deployer des validateurs sur les autres réseaux Near. 

Veillez simplement à ajuster les différents paramètres.  

Remplacer `shardnet` pour le network approprié (`mainnet` ou `testnet`) dans les différentes étapes. Notamment pour la variable d'environnement `NEAR_ENV`, le paramètre `--chain-id`, et les téléchargements éventuels (genesis, sbapshot, etc)

Vérifier sur discord quel commit utiliser avant de checkout et compiler.

Ajuster les staking pool names: `<XX>.poolv1.near` pour le `mainnet` et `<XX>.pool.f863973.m0` pour le `testnet`.

Préparer l'environnement
Et les deployer ne appelant le contrat du même nom: `poolv1.near` ou `pool.f863973.m0`.


# Sources


- https://github.com/near/stakewars-iii/blob/main/challenges/001.md
- https://github.com/near/stakewars-iii/blob/main/challenges/002.md
- https://github.com/near/stakewars-iii/blob/main/challenges/003.md
- https://github.com/near/stakewars-iii/blob/main/challenges/002.md
- https://near-nodes.io/validator/deploy-on-mainnet
