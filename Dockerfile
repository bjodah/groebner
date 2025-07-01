FROM docker.io/ubuntu:noble

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends \
        apt-transport-https \
        bzip2 \
        ca-certificates \
        ccache \
        cmake \
        curl \
        ffmpeg \
        g++ \
        gcc \
        gdb \
        git \
        gnupg2 \
        libboost-dev \
        libgmp-dev \
        m4 \
        make \
        software-properties-common \
        unzip \
        vim \
        wget \
        yasm \
        zlib1g-dev \
    && update-ca-certificates

VOLUME ["/groebner"]

WORKDIR /groebner
