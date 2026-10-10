# https://hub.docker.com/_/debian/tags?name=trixie
FROM debian:trixie
ENV SHELL="/bin/bash"

COPY . /usr/src/local/
WORKDIR /usr/src/local

RUN touch /run/.containerenv \
    && sh ./base/install.sh \
    && cp -a ./base/home/. /root/ \
    && mkdir -p /usr/local/src \
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
