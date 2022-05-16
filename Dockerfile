FROM seegno/bitcoind:0.13-alpine as base
LABEL "description"="Nitin Flask Development"
LABEL version="1.0"

COPY issuer /cert-issuer
COPY cert-tools /cert-tools


RUN apk add --update \
    bash \
    ca-certificates \
    curl \
    gcc \
    gmp-dev \
    libffi-dev \
    libressl-dev \
    linux-headers \
    make \
    musl-dev \
    python \
    python3 \
    python3-dev \
    tar \
    g++\
    libxslt-dev \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip setuptools \
    && mkdir -p /etc/cert-issuer/data/unsigned_certificates \
    && mkdir /etc/cert-issuer/data/blockchain_certificates \
    && mkdir ~/.bitcoin \
    && echo $'rpcuser=foo\nrpcpassword=bar\nrpcport=8332\nregtest=1\nrelaypriority=0\nrpcallowip=127.0.0.1\nrpcconnect=127.0.0.1\n' > /root/.bitcoin/bitcoin.conf \
    && pip3 install chainpoint>=0.0.2 \
    && sed -i.bak s/==1\.0b1/\>=1\.0\.2/g /usr/lib/python3.*/site-packages/merkletools-1.0.2-py3.*.egg-info/requires.txt \
    && pip3 install /cert-tools/. \
    && pip3 install /cert-issuer/. \
    && rm -r /usr/lib/python*/ensurepip \
    && rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache 

#WORKDIR /cert-tools
ENV FLASK_APP=/cert-tools/app.py
RUN chmod -R 776 /cert-tools
RUN chmod -R 776 /cert-issuer

######### Debug ##############
FROM base as debug
RUN pip install debugpy
CMD python3 -m debugpy --listen 0.0.0.0:5678 --wait-for-client -m flask run -h 0.0.0.0 -p 5000

######## Production ###########
FROM base as prod
CMD flask run -h 0.0.0.0 -p 5000
