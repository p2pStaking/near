#!/bin/bash 

# init ssh dir if needed
[[ ! -d "/root/.ssh" ]] && mkdir /root/.ssh && \
	 echo "${MY_IDENTITY}" >> /root/.ssh/authorized_keys && \
	chmod 700 -R /root/.ssh && \
	systemctl restart sshd


# log service to akash log
while [[ "1" -eq "1" ]]
do
bash -c "${LOG_CMD}"
done
