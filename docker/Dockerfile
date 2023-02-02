FROM p2pstaking/near-cli  
ARG NEAR_RELEASE_VERSION
RUN cd && \
	echo "building neard version $NEAR_RELEASE_VERSION" && sleep 3s  && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y python3 git jq && \
	apt-get install -y clang build-essential make && \
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
	. $HOME/.cargo/env && \
	git clone https://github.com/near/nearcore.git && \
	cd nearcore && \
	git checkout $NEAR_RELEASE_VERSION && \
	make release && \
	mkdir -p ~/.near && \
	cd ~/.near 
EXPOSE  3030 24567
COPY initialize_near.sh /root/
COPY run_near.sh /root/
COPY get_snapshot.sh /root/ 
CMD /root/run_near.sh 
