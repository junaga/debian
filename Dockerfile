FROM debian:trixie
ENV SHELL=/bin/bash

WORKDIR /usr/src/system
COPY . .

RUN sh ./instpkg.sh \
    && cp -a /etc/skel/. /root/ \
    && cp .env /root/.env \
    && mkdir -p /usr/local/dev \
    && rm -rf /var/lib/apt/lists/*

CMD ["cron", "-f"]
