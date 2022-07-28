# !!Draft!! écriture en cours

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

Bien qu'en dehors du périmètre de cette documentation, soyez miticuleux sur la sécurité de votre serveur. Notamment, veillez à:
- utiliser une authentification par clé SSH (et interdire les connexions SSH par mot de passe)
- renforcer la sécurité de votre serveur (https://www.informaticar.net/security-hardening-ubuntu-20-04/)

Pour la suite de cette documentation, nous supposerons que vous êtes connectés via SSH à votre serveur. 

# Installer et configurer un validateur NEAR

TODO

# Autres network (Mainnet, testnet, guildnet)

Les mêmes étapes s'appliquent pour deployer des validateurs sur les autres réseaux Near. 

Veillez simplement à ajuster les différents paramètre.  

Remplacer `shardnet` pour le network approprié (`mainnet` ou `testnet`) dans les différentes étapes. Notamment pour la variable d'environnement `NEAR_ENV`, le paramètre `--chain-id`, et les téléchargements éventuels (genesis, sbapshot, etc)

Vérifier sur discord quel commit utiliser avant de checkout et compiler.

Ajuster les staking pool names: `<XX>.poolv1.near` pour le `mainnet` et `<XX>.pool.f863973.m0` pour le `testnet`.

Et les deployer ne appelant le contrat du même nom: `poolv1.near` ou `pool.f863973.m0`.


# Sources

- https://github.com/near/stakewars-iii/blob/main/challenges/001.md
- https://github.com/near/stakewars-iii/blob/main/challenges/002.md
- https://github.com/near/stakewars-iii/blob/main/challenges/003.md
- https://github.com/near/stakewars-iii/blob/main/challenges/002.md
- https://near-nodes.io/validator/deploy-on-mainnet
