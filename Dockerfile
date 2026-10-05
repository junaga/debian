# https://hub.docker.com/_/debian/tags?name=trixie
FROM debian:trixie
ENV SHELL="/bin/bash"

COPY . /usr/src/system/
WORKDIR /usr/src/system

RUN sh ./instpkg.sh \
    && cp -a /etc/skel/. /root/ \
    && cp .env /root/.env \
    && mkdir -p /usr/local/dev \
    && rm -rf /var/lib/apt/lists/*

ARG RAILWAY_GIT_COMMIT_SHA
RUN if [ ! -d .git ]; then \
        git init --initial-branch=master \
        && git remote add origin https://github.com/junaga/debian.git \
        && git fetch origin master \
        && git reset --mixed "${RAILWAY_GIT_COMMIT_SHA:-origin/master}" \
        && git branch --set-upstream-to=origin/master master; \
    fi

CMD ["cron", "-f"]
