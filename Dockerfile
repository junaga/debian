FROM debian:trixie
ENV SHELL=/bin/bash

COPY . /usr/local/src/
RUN sh /usr/local/src/instpkg.sh && cp -a /etc/skel/. /root/ && cp /usr/local/src/.env /root/.env && mkdir -p /usr/local/dev && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src
CMD ["cron", "-f"]
