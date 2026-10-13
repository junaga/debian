# https://hub.docker.com/_/debian/tags?name=trixie
FROM debian:trixie

WORKDIR /usr
COPY . src/system/
RUN sh src/system/base/install.sh container
RUN rm -rf /root
RUN ln -s /usr/local/data /root

WORKDIR /usr/local
ENV SHELL="/bin/bash"
CMD mkdir -p dev data && exec sleep infinity
