Doc in progress


TODO - Description


Install Cloudmos (TODO link)

Create a wallet (TODO screenshot)

Add funds (TODO screenshot)

Deploy using Cloudmos
- click deploy
![image](https://user-images.githubusercontent.com/110183218/188599736-f4eb1633-077a-4020-bc56-5c9d207cec62.png)
- choose empty file 
![image](https://user-images.githubusercontent.com/110183218/188599891-fe3d7816-b468-4e4f-838a-b40cb0f25db2.png)

Copy and past 


```
https://raw.githubusercontent.com/p2pStaking/near/main/stake-wars/challenge17/deploy.yml
```

Edit `MY_IDENTITY` with your ssh certificate public key

![image](https://user-images.githubusercontent.com/110183218/188600399-62c1d267-b1ea-4708-8d57-5e6a783d23dd.png)

Then Clic create deployment. 

Adjust your deposit amount (5 $AKT is enough for a simple test)

![image](https://user-images.githubusercontent.com/110183218/188600683-5bc3ea04-8171-4ce2-9b39-e2a630404c55.png)

Click `deposit` and `approve` on the next popup

![image](https://user-images.githubusercontent.com/110183218/188600835-4ae6fe70-ee34-49df-840f-27fc874fcdc6.png)

Wait 1 minute until bids arrive.....
And pick the best one. Note that storage class is important (beta1=HDD, beta2=SSD, beta3=NVMe)

![image](https://user-images.githubusercontent.com/110183218/188601036-2ca4d139-d82c-4471-becb-7d9339b614bc.png)

then click `ACCEPT BID` and `APPROVE`
![image](https://user-images.githubusercontent.com/110183218/188601558-bfa08922-6e00-4dbd-8a14-178e7e96f859.png)

Wait for the transaction confirmation and the deployment 

![image](https://user-images.githubusercontent.com/110183218/188601763-fb17c737-4298-4cd4-93b4-455f229788e1.png)

![image](https://user-images.githubusercontent.com/110183218/188602828-7440c053-32a0-4220-b1f2-5b344c0d2bdd.png)

TODO : goto lease find ssh param
screen 
curl -sL https://raw.githubusercontent.com/p2pStaking/near/main/stake-wars/challenge17/install_near_testnet_chunk_only.sh  | bash - 


Optionally : check out this projet and
	- adapt Dockerfile, deploy.yml and install file to your needs
	- deploy on your dockerhub

