FROM ubuntu:xenial
LABEL maintainer="skinlayers@gmail.com"

ENV RPCUSER feathercoinrpc
ENV RPCPASSWORD OVERRIDE_ME
ENV RPCALLOWIP 127.0.0.1
ENV VERSION 0.9.6.2
ENV SHA256 c549ce221160709350db5c2c16495a552e0ddd2e631d119be81c805ee8fced72

RUN set -eux && \
    adduser --system --home /data --group feathercoin && \
    echo 'deb http://ppa.launchpad.net/bitcoin/bitcoin/ubuntu xenial main' > \
        /etc/apt/sources.list.d/bitcoin-ubuntu-bitcoin-xenial.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8842CE5E && \
    buildDeps=" \
        curl \
        pkg-config \
        build-essential \
        libtool \
        autotools-dev \
        autoconf \
        libssl-dev \
        libboost-all-dev \
        libdb4.8-dev \
        libdb4.8++-dev \
        libboost1.58-all-dev \
        libminiupnpc-dev \
    "; \
    runDeps=" \
        ca-certificates \
        libboost-filesystem1.58.0 \
        libboost-program-options1.58.0 \
        libboost-system1.58.0 \
        libboost-thread1.58.0 \
        libssl1.0.0 \
        libdb4.8++ \
        libminiupnpc10 \
    "; \
    apt-get update && apt-get -y install $buildDeps && \
    curl -LO "https://github.com/FeatherCoin/Feathercoin/archive/v${VERSION}-prod.tar.gz" && \
    echo "$SHA256  v${VERSION}-prod.tar.gz" > "v${VERSION}-prod-sha256sum.txt" && \
    sha256sum -c "v${VERSION}-prod-sha256sum.txt" && \
    tar xf "v${VERSION}-prod.tar.gz" && \
    cd "Feathercoin-${VERSION}-prod" && \
    ./autogen.sh && \
    ./configure \
        --with-miniupnpc \
        --enable-upnp-default \
        --disable-tests \
        --without-gui \
        --without-qrcode && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -r \
        "Feathercoin-${VERSION}-prod" \
        "v${VERSION}-prod.tar.gz" \
        "v${VERSION}-prod-sha256sum.txt" && \
    apt-mark manual $runDeps && \
    apt-get remove --purge -y $buildDeps $(apt-mark showauto) && \
    apt-get -y install $runDeps && \
    rm -r /var/lib/apt/lists/* && \
    chmod 0700 /data

USER feathercoin
VOLUME /data

EXPOSE 9336 9337

CMD ["sh", "-c", "feathercoind -server -printtoconsole -rpcuser=${RPCUSER} -rpcpassword=${RPCPASSWORD} -rpcallowip=${RPCALLOWIP}"]
