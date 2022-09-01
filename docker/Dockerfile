FROM debian:bullseye
SHELL ["/bin/bash", "-c"]
RUN apt update && \
	apt install -y wget  curl apt-utils && \
	apt upgrade -y && \
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \ 
	source $HOME/.cargo/env &&\
	apt install -y  ufw git jq build-essential nodejs && \
	apt remove -y nodejs && \
	curl -sL https://deb.nodesource.com/setup_18.x |  bash - && \
	apt install -y nodejs && \
	node -v && npm -v && \
	npm install -g near-cli && \
	export NEAR_ENV=shardnet && echo 'export NEAR_ENV=shardnet' >> ~/.bashrc && \
	apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python docker.io protobuf-compiler libssl-dev pkg-config clang llvm cargo && \
	apt install -y python3-pip && \
	USER_BASE_BIN=$(python3 -m site --user-base)/bin && \
	export PATH="$USER_BASE_BIN:$PATH" && \
	apt install -y clang build-essential make && \
	cd &&\
	source $HOME/.cargo/env && \
	cd && \
	git clone https://github.com/near/nearcore && \
	cd nearcore && \
	git fetch && \
	git checkout 24cbb11ce1e14aa267f787f011935a4465d3537d && \
        cargo build -p neard --release --features shardnet && \
        cp target/release/neard /usr/local/bin/neard && \
	/usr/local/bin/neard --home /root/.near init --chain-id shardnet --download-genesis &&\
	cp target/release/neard /usr/local/bin/neard && \
	rm /root/.near/config.json &&\
	wget -O /root/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/config.json
CMD /usr/local/bin/neard --home /root/.near run
