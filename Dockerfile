FROM python:3.11-slim-bookworm

MAINTAINER ping@mirceaulinic.net

ARG SALT_VERSION="3006.1"

COPY ./ /var/cache/salt-sproxy/
COPY ./master /etc/salt/master

RUN apt-get update \
 && apt-get install -y python3-zmq gcc direnv \
 && echo 'eval "$(direnv hook bash)"' >> ~/.bashrc \
 && pip --no-cache-dir install salt==$SALT_VERSION \
 && pip --no-cache-dir install /var/cache/salt-sproxy/ \
 && rm -rf /var/cache/salt-sproxy/ \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

# add task command
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin \
    && echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
