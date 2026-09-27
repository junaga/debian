FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive \
    NEEDRESTART_SUSPEND=1 \
    WORK=/usr/local \
    LANG=C.UTF-8 \
    EDITOR=micro \
    PAGER=less \
    AGENT=codex

COPY . /opt/debian/

RUN apt-get update \
    && apt-get install -y ca-certificates \
    && apt modernize-sources --assume-yes \
    && cp -r /opt/debian/base/. /etc/ \
    && rm -f /var/lib/apt/lists/*_InRelease \
    && apt-get update \
    && apt-get install -y $(cat /opt/debian/packages) \
    && cp -a /etc/skel/. /root/ \
    && pipx install --global huggingface_hub \
    && npm install --global --no-fund @openai/codex @pnp/cli-microsoft365 wrangler \
    && echo "*/2 * * * * root sh /etc/update.sh" >> /etc/crontab \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local
CMD ["sh", "-c", "cron && exec sleep infinity"]
