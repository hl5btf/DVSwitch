#!/bin/bash

### ~/.bashrc에 Alias 추가
echo "---------------------ALIAS 추가"
sudo wget -O /home/dvswitch/temp/bashrc.add https://raw.githubusercontent.com/hl5btf/DVSwitch/main/bashrc.add
sudo cat /home/dvswitch/.bashrc /home/dvswitch/temp/bashrc.add > bash_new
sudo rm /home/dvswitch/temp/bashrc.add
sudo mv bash_new /home/dvswitch/.bashrc

sudo nano ~/.bashrc
