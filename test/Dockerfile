FROM ubuntu:20.04

RUN apt update && apt install -y sudo software-properties-common

# Make a non-root user
RUN useradd --create-home --shell /bin/bash test_user
RUN passwd -d test_user
RUN adduser test_user sudo
USER test_user
ENV USER=test_user
ENV TZ=Europe/Kiev
RUN sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
WORKDIR /home/test_user

# Simulate the repo clone
RUN mkdir -p ~/.local/personal_configs
COPY . .local/personal_configs/
