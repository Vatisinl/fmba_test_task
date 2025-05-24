FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir pandas argparse

ENV SOFT=/soft
RUN mkdir -p ${SOFT} && \
    cd ${SOFT} && \
    mkdir /soft/python_script && \
    mkdir -p /ref/GRCh38.d1.vd1_mainChr/sepChrs/ 

COPY ./python_script.py ./FP_SNPs.txt ./FP_SNPs_10k_GB38_twoAllelsFormat.tsv ${SOFT}/python_script/
RUN chmod +x ${SOFT}/python_script/python_script.py

WORKDIR ${SOFT}