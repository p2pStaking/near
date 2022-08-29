# Valdator  data science


Here is a snapshot of our grafana dashboard from  our validator on Near's shardnet


![grafana_snapshot](https://user-images.githubusercontent.com/110183218/187230861-4b1a1a51-fd64-45e3-b1da-d68679a6b4a6.jpg)

It provides minimal data to quickly evaluate our validator's health. 

Is it producing expected blocks/chunks? How is its peeformance compared to other validators on the network?

This first graphs tell us if there is something wrong going on. 

Then, we use see general metrics:
 - sync lag: difference between near final block height and our current block height
 - peer connections: number of peers our validator is connected to
 - block per minute: average block production
The first two metrics tell us more about our node's connectivity. The average block per minute is the easiest way to see if the network runs slower than usual.


Also, we use prometheus alert manager to trigger notifications when our validator uptime is lower than 90% or the average block per minute is lower than expected.
We also have a similar set up with general metrics using node-exporter (monitoring and alerting on CPU/Memory usage, disk storage, etc). 
This way we can step in before problems occur (or least as soon as they raise).
