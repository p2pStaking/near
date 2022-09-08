#!/bin/bash 

# init ssh dir if needed
[[ ! -d "/root/.ssh" ]] && mkdir /root/.ssh && \
	 echo "${MY_IDENTITY}" >> /root/.ssh/authorized_keys && \
	chmod 700 -R /root/.ssh && \
	systemctl restart sshd


# log service to akash log
mkdir -p $( dirname $LOG_FILE )
touch ${LOG_FILE}
tail -f ${LOG_FILE}
echo "lost connection to log file" >>  ${LOG_FILE}"
sleep infinity
