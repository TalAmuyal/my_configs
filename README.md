[![Ubuntu - CircleCI](https://circleci.com/gh/TalAmuyal/my_configs.svg?style=shield)](https://github.com/TalAmuyal/my_configs)
[![Mac OS X - Travis](https://travis-ci.com/TalAmuyal/my_configs.svg?branch=master)](https://github.com/TalAmuyal/my_configs)

This is my configurations repo.


# Installation

Paste into a terminal:

```
mkdir -p ~/.local && cd ~/.local && git clone https://github.com/TalAmuyal/my_configs.git && bash ./my_configs/setup.sh
```


# NeoVim TODOs

- Enable spell checker for comments and symbols
- Enable Smart tabs (Tabs/spaces for indentation, spaces for alignment)


# Handy stuff

## Set SSH in .git/config

```
[remote "origin"]
	url = git@github.com:ORG/REPO.git
	fetch = +refs/heads/*:refs/remotes/origin/*
```
