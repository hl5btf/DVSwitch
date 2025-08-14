#!/bin/bash

# 아래의 내용을 실행한 후에 현재의 파일(rpi_image.sh)을 실행한다.
# 1. OS 설치
# 2. wifi 설정
# 3. setup
# 4. dvsmu_upgarade.sh
# 상세 내용은 "Notion - 이미지파일 만들기" 참조.

#=======================================================
# pimodel_setup.sh 파일 생성 및 실행 권한 부여
# 디바이스(rpi3,4,5)에 따른 hostname 자동변경, machine-id 초기화 등을 위한 스크립트
echo ">>> <pimodel_setup.sh> changing hostname according to device and initialize machine-id"

sudo cat <<'EOF' > /usr/local/bin/pimodel_setup.sh
#!/bin/bash

# Pi 모델명 추출
MODEL=$(tr -d '\0' < /proc/device-tree/model)

# 간단한 모델명 매핑
case "$MODEL" in
    *"Raspberry Pi 3"*)      NEW_HOSTNAME="pi3" ;;
    *"Raspberry Pi 4"*)      NEW_HOSTNAME="pi4" ;;
    *"Raspberry Pi 5"*)      NEW_HOSTNAME="pi5" ;;
    *"Raspberry Pi Zero 2"*) NEW_HOSTNAME="pi0w2" ;;
    *)                       NEW_HOSTNAME="pi-unknown" ;;
esac

# 현재 hostname 확인
CURRENT_HOSTNAME=$(cat /etc/hostname)

# hostname 변경
if [[ "$CURRENT_HOSTNAME" != "$NEW_HOSTNAME" ]]; then
    echo "Setting hostname to $NEW_HOSTNAME"
    echo "$NEW_HOSTNAME" | tee /etc/hostname
    sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts
    hostname "$NEW_HOSTNAME"
fi

# machine-id 초기화
echo "Resetting machine-id..."
rm -f /etc/machine-id
systemd-machine-id-setup

# 로그 기록
echo "[\$(date)] Model: \$MODEL, Hostname set to: \$NEW_HOSTNAME" >> /var/log/pimodel_setup.log
EOF

# 실행 권한 부여
sudo chmod +x /usr/local/bin/pimodel_setup.sh

echo "[✓] /usr/local/bin/pimodel_setup.sh 저장 완료"

#-------------------------------------------------------
# systemd 서비스 등록 및 활성화
echo
echo ">>> enable pimodel-setup.service"

# pimodel-setup.service 생성
sudo cat <<'EOF' > /etc/systemd/system/pimodel-setup.service
[Unit]
Description=Auto-set short hostname and machine-id based on Pi model
After=network-pre.target

[Service]
ExecStart=/usr/local/bin/pimodel_setup.sh
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF

echo "[✓] /etc/systemd/system/pimodel-setup.service 저장 완료"

# 서비스 활성화
sudo systemctl daemon-reexec
sudo systemctl enable pimodel-setup.service

#=======================================================
# 한국시간으로 설정(Bookworm에서)
echo
echo ">>> change timezone to Asia/Seoul"

sudo timedatectl set-timezone Asia/Seoul

#=======================================================
# Nanum, Noto CJK 폰트 설치
echo
echo ">>> change font to Nanum, Noto CJK"

sudo apt update
sudo apt install fonts-nanum fonts-unfonts-core fonts-noto-cjk

#=======================================================

# /boot/firmware 폴더에 파일 설치
echo
echo ">>> downloading files. dvsconfig.txt, dvsSetup.exe, dvsNetwork.exe, network.txt"

# /boot/firmware/dvsconfig.txt
sudo wget -O /boot/firmware/dvsconfig.txt https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dvsconfig.txt > /dev/null 2>&1
# chg 의 기본값이 73으로 되어 있음

# /boot/firmware/dvsSetup.exe
sudo wget -O /boot/firmware/dvsSetup.exe https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dvsSetup.exe > /dev/null 2>&1

# /boot/firmware/dvsNetwork.exe
sudo wget -O /boot/firmware/dvsNetwork.exe https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dvsNetwork.exe > /dev/null 2>&1

#/boot/firmware/network.txt
if [[ ! -f "/boot/firmware/network.txt" ]]; then
	sudo wget -O /boot/firmware/network.txt https://raw.githubusercontent.com/hl5btf/DVSwitch/main/network.txt > /dev/null 2>&1
fi

#=======================================================
# dvsstart.service, dvsstart-runner.sh 설치
echo
echo ">>> downloading files. dvsstart.service, dvsstart-runner.sh"

# dvsstart.service
sudo wget -O /etc/systemd/system/dvsstart.service https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dvsstart.service > /dev/null 2>&1

# dvsstart-runner.sh
sudo wget -O /usr/local/bin/dvsstart-runner.sh https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dvsstart-runner.sh > /dev/null 2>&1
sudo chmod +x /usr/local/bin/dvsstart-runner.sh

# 서비스 활성화
# dvsstart.service의 내용을 변경하면 재활성화 필요
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable dvsstart.service

echo
echo ">>> finished rpi_image.sh"
echo

exit 0
