#!/bin/bash

DATE=$(date +%y%m%d)
NEARDIR=$HOME/.near/
BACKUPDIR=$HOME/backup

mkdir -p $BACKUPDIR

sudo systemctl stop neard.service

wait

echo "$(date): NEAR node was stopped" 


if [ -d "$BACKUPDIR" ]; then
    echo "$(date): Backup started" 


    # Submit backup completion status, you can use healthchecks.io, betteruptime.com or other services
    # Example
    # curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/xXXXxXXx-XxXx-XXXX-XXXx-...

    rm $BACKUPDIR/*tar.gz
    tar -cvzf ${BACKUPDIR}/near_${DATE}.tar.gz --directory $NEARDIR data/
    echo "$(date): Backup completed" 
else
    echo $BACKUPDIR is not created. Check your permissions.
    exit 0
fi

sudo systemctl start neard.service

echo "$(date): NEAR node was started" 

