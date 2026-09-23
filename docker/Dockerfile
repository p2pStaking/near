ARG NEAR_RELEASE_VERSION=2.13.4

FROM node:22-bookworm AS near-cli
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl jq ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g near-cli
CMD ["sh", "-c", "$@"]

FROM near-cli AS build
ARG NEAR_RELEASE_VERSION
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 git clang build-essential make pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cd /root && \
    git clone --depth 1 --branch $NEAR_RELEASE_VERSION https://github.com/near/nearcore.git && \
    cd nearcore && \
    make release

FROM near-cli AS final
COPY --from=build /root/nearcore/target/release/neard /usr/local/bin/
RUN mkdir -p /root/.near
EXPOSE 3030 24567
COPY initialize_near.sh run_near.sh get_snapshot.sh /root/
CMD ["/root/run_near.sh"]
