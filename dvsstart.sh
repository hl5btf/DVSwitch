#!/bin/bash

file=dvsstart_setup.sh

sudo wget https://raw.githubusercontent.com/hl5btf/DVSwitch/main/$file > /dev/null 2>&1

sudo chmod +x $file

sudo ./$file

sudo rm $file

#------------------------------------------------------------

sudo wget https://github.com/hl5ky/dvsmu/raw/main/setup > /dev/null 2>&1

sudo chmod +x setup

sudo ./setup

sudo rm setup
