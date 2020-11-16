#!/bin/bash

### ~/.bashrc에 Alias 추가
echo "---------------------ALIAS 추가"
sudo wget bashrc.add https://raw.githubusercontent.com/hl5btf/DVSwitch/main/bashrc.add
sudo cat /home/dvswitch/.bashrc bashrc.add > bash_new
sudo rm bashrc.add
sudo mv bash_new /home/dvswitch/.bashrc

# sudo nano /home/dvswitch/.bashrc
