#!/bin/bash

# 두 개의 파일이 모두 다운로드 가능한지 확인후 진행
file1="dvsstart_dvsconfig.sh"
file2="dvsmu_upgrade.sh"
url1="https://raw.githubusercontent.com/hl5btf/DVSwitch/main/$file1"
url2="https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file2"

if sudo wget -q "$url1" -O "/usr/local/dvs/$file1" && sudo wget -q "$url2" -O "/usr/local/dvs/$file2"; then
    :
else
    echo "초기설정파일의 다운로드가 되지 않습니다.  인터넷 연결을 확인후 다시 부팅해 주세요."
    echo
    exit 1
fi

(
#--------------------------------------------------------------
# 업그레이드

sudo apt-get update
sudo apt-get upgrade

#--------------------------------------------------------------
# dvsconfig.txt에 설정한 항목을 이용하여 초기 설정을 자동으로 하는 루틴
sudo chmod +x /usr/local/dvs/$file1

sudo /usr/local/dvs/$file1

#------------------------------------------------------------
# 이미지파일을 만든 이후에 프로그램의 업그레이드, 파일의 변경 등이 있는 내용 적용
sudo chmod +x /usr/local/dvs/$file2

sudo /usr/local/dvs/$file2

) > /dev/null 2>&1 &

echo -n "please wait about 5 min "
while kill -0 $! 2>/dev/null; do
    echo -n "."
    sleep 1
done

echo -e "\n초기설정이 완료되었습니다."
echo

sudo sed -i '/dvsstart\.sh/d' /etc/crontab > /dev/null 2>&1

sudo rm /usr/local/dvs/$file1 > /dev/null 2>&1

sudo rm /usr/local/dvs/$file2 > /dev/null 2>&1
