#!/bin/bash

clear
docker build --tag my_config_test -f test/Dockerfile .
docker run --rm -i my_config_test /bin/bash .local/personal_configs/setup.sh
