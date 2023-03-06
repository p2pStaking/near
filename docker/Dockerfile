FROM p2pstaking/near-cli AS build 
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
	make release  
FROM node:16.18.1-bullseye 
COPY --from=build /root/nearcore/target/release/neard /usr/local/bin/
COPY --from=build /usr/local/bin/near /usr/local/bin/
RUN	mkdir -p ~/.near && \
	cd ~/.near 
EXPOSE  3030 24567
COPY initialize_near.sh /root/
COPY run_near.sh /root/
COPY get_snapshot.sh /root/ 
CMD /root/run_near.sh 
