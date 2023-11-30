FROM python:3.11-slim-bookworm

MAINTAINER ping@mirceaulinic.net

ARG SALT_VERSION="3006.1"

COPY ./ /var/cache/salt-sproxy/
COPY ./master /etc/salt/master

ENV PATH=$PATH:~/.local/bin:/usr/local/bin:~/.arkade/bin DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xA2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B | gpg --dearmor -o /etc/apt/keyrings/apt-fast.gpg \
 && apt-get update \
 && apt-get install apt-fast \
 && echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections \
 && echo debconf apt-fast/dlflag boolean true | debconf-set-selections \
 && echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections \
 && echo 'MIRRORS=( 'http://deb.debian.org/debian','http://ftp.debian.org/debian, http://ftp2.de.debian.org/debian, http://ftp.de.debian.org/debian, ftp://ftp.uni-kl.de/debian' )' >> /etc/apt-fast.conf \
 && apt-fast install -y python3-zmq gcc direnv curl wget aria2 axel file tree ncdu neofetch htop dstat iotop unzip git \
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
RUN /usr/.local/bin/task
