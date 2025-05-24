FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    build-essential \
    make \
    autoconf \
    bash \
    perl \
    wget \
    ncurses-dev \
    cmake \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

ARG NUM_CORES=4

ENV SOFT=/soft
RUN mkdir -p ${SOFT} && \
    cd ${SOFT} && \
    mkdir samtools-1.21 htslib-1.21 libdeflate-1.24 bcftools-1.21 vcftools-0.1.17

#samtools of version 1.21, sep 12, 2024
RUN wget https://github.com/samtools/samtools/releases/download/1.21/samtools-1.21.tar.bz2 && \
tar -xjf samtools-1.21.tar.bz2  && \
 rm samtools-1.21.tar.bz2 && \
 cd samtools-1.21 && \
 ./configure --prefix=${SOFT}/samtools-1.21 && \
 make -j${NUM_CORES} && \
 make install && \
 cd .. && \
 rm -rf samtools-1.21

#htslib of version 1.21, sep 12, 2024
RUN wget https://github.com/samtools/htslib/releases/download/1.21/htslib-1.21.tar.bz2 && \
tar -xjf htslib-1.21.tar.bz2 && \
 rm htslib-1.21.tar.bz2 && \
 cd htslib-1.21 && \
 ./configure --prefix=${SOFT}/htslib-1.21 && \
 make -j${NUM_CORES} && \
 make install && \
 cd .. && \
 rm -rf htslib-1.21

#libdeflate of version 1.24, may 2025
RUN wget https://github.com/ebiggers/libdeflate/releases/download/v1.24/libdeflate-1.24.tar.gz && \
tar -xzf libdeflate-1.24.tar.gz  && \
 rm libdeflate-1.24.tar.gz && \
 cd libdeflate-1.24 && \
 cmake -B build -DCMAKE_INSTALL_PREFIX=${SOFT}/libdeflate-1.24 && \
 cmake --build build && \
 cmake --install build && \
 cd .. && \
 rm -rf libdeflate-1.24


#bcftools of version 1.21, sep 12, 2024
RUN wget https://github.com/samtools/bcftools/releases/download/1.21/bcftools-1.21.tar.bz2 && \
tar -xjf bcftools-1.21.tar.bz2 && \
 rm bcftools-1.21.tar.bz2 && \
 cd bcftools-1.21 && \
 ./configure --prefix=${SOFT}/bcftools-1.21 && \
 make && \
 make install && \
 cd .. && \
 rm -rf bcftools-1.21

#vcftools of version 0.1.17, may 2025
RUN wget https://github.com/vcftools/vcftools/releases/download/v0.1.17/vcftools-0.1.17.tar.gz && \
tar -xzf vcftools-0.1.17.tar.gz  && \
 rm vcftools-0.1.17.tar.gz && \
 cd vcftools-0.1.17 && \
 ./configure --prefix=${SOFT}/vcftools-0.1.17 && \
 make && \
 make install && \
 cd .. && \
 rm -rd vcftools-0.1.17 && \
 rm -rf /tmp/* && \
 rm -rf /run/* && \
 rm -rf /var/log/*



ENV PATH="${SOFT}/samtools-1.21/bin:${SOFT}/htslib-1.21/bin:${SOFT}/libdeflate-1.24/bin:${SOFT}/bcftools-1.21/bin:${SOFT}/vcftools-0.1.17/bin:$PATH"

ENV SAMTOOLS="" \
    HTSLIB="" \
    BCFTOOLS="" \
    VCFTOOLS="" \
    LIBDEFLATE=""
ENV SAMTOOLS="${SOFT}/samtools-1.21/bin/samtools" \
    HTSLIB="${SOFT}/htslib-1.21/bin/htslib" \
    BCFTOOLS="${SOFT}/bcftools-1.21/bin/bcftools" \
    VCFTOOLS="${SOFT}/vcftools-0.1.17/bin/vcftools" \
    LIBDEFLATE="${SOFT}/libdeflate-1.24/bin/libdeflate"

WORKDIR ${SOFT}