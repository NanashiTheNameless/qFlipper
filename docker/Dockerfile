FROM ubuntu:24.04

WORKDIR /project

COPY install-deps.sh /tmp/install-deps.sh
RUN /tmp/install-deps.sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git config --global --replace-all safe.directory '*'

COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]
