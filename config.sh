#!/bin/bash

# - 비밀번호 변경
echo "-----------------------비밀번호 변경"
passwd

# - WIFI 설정
echo "--------------------------WIFI 설정"
sudo wget -O /etc/wpa_supplicant/wpa_supplicant.conf https://raw.githubusercontent.com/hl5btf/DVSwitch/main/wpa_supplicant.conf

# - TimeZone 설정
echo "---------------------TIME ZONE 설정"
sudo cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime

### /etc/dhcpcd.conf 내용변경
echo "-----------------------DHCPCD.CONF 변경"
sudo wget https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dhcpcd.add
sudo cat /etc/dhcpcd.conf dhcpcd.add > dhcpcd.conf
sudo rm dhcpcd.add
sudo mv dhcpcd.conf /etc/dhcpcd.conf

# dhcpcd.conf 심볼릭 링크
echo "-----------------------dhcpcd.conf 심볼릭 링크 설정"
sudo cp /etc/dhcpcd.conf /boot/dhcpcd.txt
sudo mv /etc/dhcpcd.conf /etc/dhcpcd.bak
sudo ln -s /boot/dhcpcd.txt /etc/dhcpcd.conf
	
# wpa_supplicant 심볼릭링크
echo "-----------------------wpa_supplicant.conf 심볼릭 링크 설정"
sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /boot/wpa_supplicant.txt
sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.bak
sudo ln -sb /boot/wpa_supplicant.txt /etc/wpa_supplicant/wpa_supplicant.conf
 
 ### ~/.bashrc에 Alias 추가
echo "---------------------ALIAS 추가"
sudo wget https://raw.githubusercontent.com/hl5btf/DVSwitch/main/bashrc.add
sudo cat ~/.bashrc bashrc.add > bashrc
sudo rm bashrc.add
sudo mv bashrc ~/.bashrc

### PATH 추가
echo "---------------------PATH 추가"
file=/etc/profile
path=$(echo $PATH)
var=${path}:/opt/MMDVM_Bridge
sudo sed -i "/\/usr\/local\/games/ c PATH=\"$var\"" $file

### Shellinabox 설치
echo "---------------------ShellInBox 설치 및 설정"
sudo apt-get update
sudo apt-get install shellinabox

# Shellinabox 설정
file=/etc/default/shellinabox
var=SHELLINABOX_PORT=7388
sudo sed -i "/PORT=/ c $var" $file
var="SHELLINABOX_ARGS=\"--no-beep --disable-ssl \""
sudo sed -i "/ARGS=/ c $var" $file
var=OPTS=\"--localhost-only\"
echo "$var" | sudo tee -a $file

### dvsstart.sh 파일 설치
echo "---------------------dvsstart.sh 설치"
sudo wget -O /etc/dvsstart.sh https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dvsstart.sh
sudo chmod +x /etc/dvsstart.sh

### /etc/rc.local 에 dvsstart.sh 실행 내용 추가
file=/etc/rc.local
var="sudo /etc/dvsstart.sh &"
sudo sed -i'' -r -e "/exit 0/i\\$var" $file

### temp.sh 한국용으로 변경 (CPU사용율 표시)
echo "---------------------temp.sh 설치"
sudo wget https://raw.githubusercontent.com/hl5btf/DVSwitch/main/temp.sh
sudo mv temp.sh /usr/local/dvs/temp.sh
sudo chmod +x /usr/local/dvs/temp.sh

### RX_freq, TX_freq 000000000 으로 변경
echo "---------------------FREQ 변경 000000000"
file=/var/lib/dvswitch/dvs/var.txt
sudo sed -i -e "/^rx_freq=/ c rx_freq=000000000" $file
sudo sed -i -e "/^tx_freq=/ c rx_freq=000000000" $file

### boot 폴더에 파일 설치
echo "---------------------boot 폴더에 파일 설치"
sudo wget -O /boot/dvsNetwork.exe https://github.com/hl5btf/DVSwitch/raw/main/boot/dvsNetwork.exe
sudo wget -O /boot/dvsSetup.exe https://github.com/hl5btf/DVSwitch/raw/main/boot/dvsSetup.exe
sudo wget -O /boot/dvsconfig.txt https://github.com/hl5btf/DVSwitch/raw/main/boot/dvsconfig.txt
