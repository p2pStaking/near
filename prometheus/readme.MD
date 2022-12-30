# Usage 

Once neard is synced, can be used to export validator state through docker 

Dry run : `docker exec production-neard-1 /root/push_near.sh --debug`

With a pushgateway local instance, it can be scheduled with a cron job, for instance: 

```
*/2 * * * * /usr/bin/docker exec production-neard-1 /root/push_near.sh
``` 
