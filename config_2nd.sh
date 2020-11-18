#!/bin/bash

### ~/.bashrc에 Alias 추가

file=/home/dvswitch/.bashrc
text=Analog_Bridge

if [[ -z `sudo grep $text $file` ]]; then
  echo "---------------------ALIAS 추가"
  sudo wget bashrc.add https://raw.githubusercontent.com/hl5btf/DVSwitch/main/bashrc.add
  sudo cat $file bashrc.add > bash_new
  sudo rm bashrc.add
  sudo mv bash_new $file
fi

# sudo nano $file
