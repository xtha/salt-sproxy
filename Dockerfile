FROM python:3.11-slim-bookworm

MAINTAINER ping@mirceaulinic.net

ARG SALT_VERSION="3006.1"

ARG USERNAME=docker
ARG USER_UID=1000
ARG USER_GID=$USER_UID


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

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

WORKDIR /home/docker

# add task command
RUN wget https://github.com/go-task/task/releases/download/v3.32.0/task_linux_amd64.deb \
    && sudo dpkg -i task_linux_amd64.deb \
    && rm -f task_linux_amd64.deb \
    && echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
COPY ./Taskfile.yml /root/Taskfile.yml
RUN sudo task
