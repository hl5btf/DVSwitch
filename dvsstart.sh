#!/bin/bash

echo
echo
echo "----------------------------------------------------"
echo
echo "------------초기 설정을 시작합니다 ------------------"
echo
# 두 개의 파일이 모두 다운로드 가능한지 확인후 진행
file1="dvsstart_setup.sh"
file2="setup"
url1="https://raw.githubusercontent.com/hl5btf/DVSwitch/main/$file1" > /dev/null 2>&1
url2="https://github.com/hl5ky/dvsmu/raw/main/$file2" > /dev/null 2>&1

if sudo wget -q "$url1" -O "$file1" && sudo wget -q "$url2" -O "$file2"; then
    :
else
    echo "설정파일의 다운로드가 되지 않습니다."
    echo
    echo "인터넷 연결을 확인후 다시 부팅해 주세요."
    echo
    exit 1
fi
#--------------------------------------------------------------
# dvsconfig.txt에 설정한 항목을 이용하여 초기 설정을 자동으로 하는 루틴
file=dvsstart_setup.sh

sudo wget https://raw.githubusercontent.com/hl5btf/DVSwitch/main/$file > /dev/null 2>&1

sudo chmod +x $file

sudo ./$file

sudo rm $file

#------------------------------------------------------------
# 이미지파일을 만든 이후에 프로그램의 업그레이드, 파일의 변경 등이 있는 내용 적용
sudo wget https://github.com/hl5ky/dvsmu/raw/main/setup > /dev/null 2>&1

sudo chmod +x setup

sudo ./setup

sudo rm setup
