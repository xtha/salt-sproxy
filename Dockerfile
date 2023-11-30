FROM python:3.11-slim-bookworm

MAINTAINER ping@mirceaulinic.net

ARG SALT_VERSION="3006.1"

COPY ./ /var/cache/salt-sproxy/
COPY ./master /etc/salt/master

RUN apt-get update \
 && apt-get install -y python3-zmq gcc direnv curl wget aria2 axel file tree ncdu neofetch htop dstat iotop unzip \
 && echo 'eval "$(direnv hook bash)"' >> ~/.bashrc \
 && pip --no-cache-dir install salt==$SALT_VERSION \
 && pip --no-cache-dir install /var/cache/salt-sproxy/ \
 && rm -rf /var/cache/salt-sproxy/ \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

# add task command
RUN sh -x -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin \
    && echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc \
    && pwd \
    && ls; cat Taskfile.yml
    #&& wget https://github.com/CatchZeng/dingtalk/releases/download/v1.5.0/dingtalk-linux-amd64.zip \
    #&& unzip -d /usr/local/bin dingtalk-linux-amd64.zip \
    #&& chmod +x /usr/local/bin/dingtalk
    # cd /tmp ; wget https://github.com/upx/upx/releases/download/v4.2.1/upx-4.2.1-amd64_linux.tar.xz && tar xf upx-4.2.1-amd64_linux.tar.xz && mv upx-4.2.1-amd64_linux/upx /usr/local/bin/ && chmod +x /usr/local/bin/upx
    
COPY Taskfile.yml ~/Taskfile.yml
#COPY --from=catchzeng/dingtalk /usr/local/bin/dingtalk /usr/local/bin/dingtalk

