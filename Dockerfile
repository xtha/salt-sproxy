FROM python:3.11-slim-bookworm

MAINTAINER ping@mirceaulinic.net

ARG SALT_VERSION="3006.1"

COPY ./ /var/cache/salt-sproxy/
COPY ./master /etc/salt/master

ENV PATH=$PATH:~/.local/bin:/usr/local/bin:~/.arkade/bin DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y python3-zmq gcc direnv curl wget xz-utils bzip2 p7zip sudo gnupg \
 && echo 'eval "$(direnv hook bash)"' >> ~/.bashrc \
 && pip --no-cache-dir install salt==$SALT_VERSION \
 && pip --no-cache-dir install /var/cache/salt-sproxy/ \
 && rm -rf /var/cache/salt-sproxy/ \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /root
# add task command
RUN wget https://github.com/go-task/task/releases/download/v3.32.0/task_linux_amd64.deb \
    && dpkg -i task_linux_amd64.deb \
    && rm -f task_linux_amd64.deb \
    && echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
    
COPY ./Taskfile.yml /root/Taskfile.yml
RUN task
