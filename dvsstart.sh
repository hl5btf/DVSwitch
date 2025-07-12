#!/bin/bash

#file=dvsstart_setup.sh
file=dvsstart_setup.sh

sudo wget https://raw.githubusercontent.com/hl5btf/DVSwitch/main/$file

sudo chmod +x $file

sudo ./$file
