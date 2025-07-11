#!/bin/bash

#----설정후 확인 사항---------------------------------------------------
# putty로 연결하여 비밀번호 확인
# date   (시간 확인)
# sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
# sudo nano /etc/dhcpcd.conf
# sudo nano /boot/wpa_supplicant.txt
# sudo nano /boot/dhcpcd.txt
# sudo nano /etc/profile  (PATH 확인)
# sudo nano /etc/default/shellinabox
# sudo nano /etc/dvsstart.sh
# sudo nano /etc/rc.local
# sudo nano /usr/local/dvs/temp.sh   (cpu_usage 확인)
# sudo nano /home/dvswitch/.bashrc  (alias 확인)
# sudo nano /var/lib/dvswitch/dvs/var.txt  (주파수 000000000)
# sudo nano /etc/cron.d/chk_temp   (온도설정 심볼릭 링크)
# cd /boot
# (파일 확인 dvsconfig.txt,  dvsSetup.txt,   dvsNetwork.exe)
#----설정후 확인 사항---------------------------------------------------


# - 비밀번호 변경
#passwd
echo
echo "-----------------------비밀번호 변경"
echo "RASPI-CONFIG를 실행합니다"
echo "ESC 를 누르면 비밀번호 설정이 중단됨"
echo "ENTER를 누르시오"
echo
read x
sudo raspi-config

echo
echo "update/upgrade 실행"
echo "시간이 오래(10분 이상) 걸리고, 중간에 멈춘 것처럼 보일 수도 있음."
echo "시작 후에 (Y/n) 질문에는 Y를 눌러주세요."
echo "ENTER를 누르면 update/upgrade를 진행합니다."
echo
read x

# update / upgrade
sudo apt-get update
sudo apt-get upgrade

# - WIFI 설정
echo "--------------------------WIFI 설정"
file=/etc/wpa_supplicant/wpa_supplicant.conf
# 파일이 없으면 덮어쓰기
if [ ! -f "$file" ]; then
sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSwitch/main/wpa_supplicant.conf
rfkill block all
rfkill unblock all
sudo ifconfig wlan0 up
fi

# - TimeZone 설정
echo "---------------------TIME ZONE 설정"
sudo cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime

### /etc/dhcpcd.conf 내용변경
file=/etc/dhcpcd.conf
text=192.168.0.160

if [[ -z `sudo grep $text $file` ]]; then
  echo "-----------------------DHCPCD.CONF 변경"
  sudo wget dhcpcd.add https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dhcpcd.add
  sudo cat $file dhcpcd.add > dhcpcd.conf
  sudo rm dhcpcd.add
  sudo mv dhcpcd.conf $file
fi

# dhcpcd.conf 심볼릭 링크
file=/boot/dhcpcd.txt

if [ ! -e $file ]; then
  echo "-----------------------dhcpcd.conf 심볼릭 링크 설정"
  sudo cp /etc/dhcpcd.conf /boot/dhcpcd.txt
  sudo mv /etc/dhcpcd.conf /etc/dhcpcd.bak
  sudo ln -s /boot/dhcpcd.txt /etc/dhcpcd.conf
fi

# wpa_supplicant 심볼릭링크
file=/boot/wpa_supplicant.txt

if [ ! -e $file ]; then
  echo "-----------------------wpa_supplicant.conf 심볼릭 링크 설정"
  sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /boot/wpa_supplicant.txt
  sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.bak
  sudo ln -sb /boot/wpa_supplicant.txt /etc/wpa_supplicant/wpa_supplicant.conf
fi

### PATH 추가
file=/etc/profile
text=MMDVM_Bridge

if [[ -z `sudo grep $text $file` ]]; then
  echo "---------------------PATH 추가"
  path=$(echo $PATH)
  var=${path}:/opt/MMDVM_Bridge
  sudo sed -i "/\/usr\/local\/games/ c PATH=\"$var\"" $file
fi

### Shellinabox 설치
file=/etc/default/shellinabox
# 파일이 없으면 실행
if [ ! -e $file ]; then
  echo "---------------------ShellInaBox 설치 및 설정"
  sudo apt-get update
  sudo apt-get install shellinabox
  # Shellinabox 설정
  var=SHELLINABOX_PORT=7388
  sudo sed -i "/PORT=/ c $var" $file
  var="SHELLINABOX_ARGS=\"--no-beep --disable-ssl \""
  sudo sed -i "/ARGS=/ c $var" $file
  var=OPTS=\"--localhost-only\"
  echo "$var" | sudo tee -a $file
fi

### dvsstart.sh 파일 설치
file=/etc/dvsstart.sh

if [ ! -e $file ]; then
  echo "---------------------dvsstart.sh 설치"
  sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dvsstart.sh
  sudo chmod +x $file
fi

### /etc/rc.local 에 dvsstart.sh 실행 내용 추가
file=/etc/rc.local
text=dvsstart.sh

if [[ -z `sudo grep $text $file` ]]; then
  var="sudo /etc/dvsstart.sh &"
  sudo sed -i'' -r -e "/exit 0/i\\$var" $file
fi

### temp.sh 한국용으로 변경 (CPU사용율 표시)
file=/usr/local/dvs/temp.sh
text=cpu_usage

if [[ -z `sudo grep $text $file` ]]; then
  echo "---------------------temp.sh 설치"
  sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSwitch/main/temp.sh
  sudo chmod +x $file
fi

### chk_temp 심볼릭 링크
if [ ! -e /etc/cron.d/chk_temp ]; then
  sudo ln -s /var/lib/dvswitch/dvs/chk_temp /etc/cron.d/chk_temp
fi

### RX_freq, TX_freq 430000000 으로 변경
file=/var/lib/dvswitch/dvs/var.txt
text=430000000

if [[ -z `sudo grep $text $file` ]]; then
  echo "---------------------FREQ 변경 430000000"
  sudo sed -i -e "/^rx_freq=/ c rx_freq=430000000" $file
  sudo sed -i -e "/^tx_freq=/ c rx_freq=430000000" $file
fi

### boot 폴더에 파일 설치
echo "---------------------boot 폴더에 파일 설치"
file=/boot/dvsNetwork.exe
if [ ! -e $file ]; then
  sudo wget -O $file https://github.com/hl5btf/DVSwitch/raw/main/boot/dvsNetwork.exe
fi

file=/boot/dvsSetup.exe
if [ ! -e $file ]; then
  sudo wget -O $file https://github.com/hl5btf/DVSwitch/raw/main/boot/dvsSetup.exe
fi

file=/boot/dvsconfig.txt
if [ ! -e $file ]; then
  sudo wget -O $file https://github.com/hl5btf/DVSwitch/raw/main/boot/dvsconfig.txt
fi

### 2nd config routine
sudo wget https://raw.githubusercontent.com/hl5btf/DVSwitch/main/config_2nd.sh
sudo chmod +x config_2nd.sh
sudo ./config_2nd.sh

sudo rm config_2nd.sh
sudo rm config.sh
