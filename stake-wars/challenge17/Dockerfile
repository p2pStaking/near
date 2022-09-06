FROM ubuntu:focal as build-systemd
RUN apt update && \
        apt install -y curl apt-utils screen vim wget python3  && \
        wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /usr/local/bin/systemctl && \
        wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/journalctl3.py -O /usr/local/bin/journalctl && \
        chmod +x /usr/local/bin/systemctl && \ 
        chmod +x /usr/local/bin/journalctl && \
	apt install -yq ssh 
EXPOSE 22 3030 24567
COPY log.sh /root
COPY sshd_config /etc/ssh/sshd_config
CMD /root/log.sh 
