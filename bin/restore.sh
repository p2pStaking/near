#! /bin/bash

NEARDIR=$HOME/.near

read -e -p 'backup path: ' BACKUP

echo "$(date): Recovery started"

sudo systemctl stop neard.service
echo "$(date): Near service stopped"

cd $NEARDIR/
rm -Rf data
echo "$(date): Database deleted, exctracting data from backup"

tar -xvzf $BACKUP 

#sudo systemctl start neard.service
echo "$(date): Near service started"

