#!/bin/bash

# /usr/local/bin/dvsstart-runner.sh

# /etc/systemd/system/dvsstart.service에서 dvsstart-runner.sh를 실행할때 root로 실행하기 때문에 아래의 스크립트에는 sudo를 사용할 필요없음.

BOOT_FLAG="/boot/firmware/dvsconfig.txt"
LOG_FILE="/var/log/dvswitch/dvsstart-run.log"
DVS_SCRIPT="/etc/dvsstart.sh"
DVS_URL="https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dvsstart.sh"
MAX_LINES=100

# 로그 파일 생성 및 초기 기록
mkdir -p "$(dirname "$LOG_FILE")"
[ -f "$LOG_FILE" ] || touch "$LOG_FILE"
echo "[DVSSTART] Service started at $(date)" >> "$LOG_FILE"

# 로그 줄 수 제한
TOTAL_LINES=$(wc -l < "$LOG_FILE")
if [ "$TOTAL_LINES" -gt "$MAX_LINES" ]; then
    tail -n $MAX_LINES "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

# /boot 마운트될 때까지 대기
while [ ! -f "$BOOT_FLAG" ]; do
    echo "[DVSSTART] Waiting for /boot mount..." >> "$LOG_FILE"
    sleep 2
done
echo "[DVSSTART] /boot detected!" >> "$LOG_FILE"

# 설정값 확인
source "$BOOT_FLAG"
CHG="${chg:-0}"
if [ "$CHG" != "1" ]; then
    echo "[DVSSTART] Skipping (chg=$CHG)" >> "$LOG_FILE"
    exit 0
fi

echo "[DVSSTART] chg=1 detected → Starting dvsstart.sh with retry loop..." >> "$LOG_FILE"

# 인터넷 연결 확인 후 설치 및 실행
while true; do
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        echo "[DVSSTART] Internet OK → running dvsstart.sh" >> "$LOG_FILE"

        wget -q -O "$DVS_SCRIPT" "$DVS_URL"
        chmod +x "$DVS_SCRIPT"
	"$DVS_SCRIPT"
		
	if [ $? -eq 0 ]; then
            echo "[DVSSTART] dvsstart.sh success → marking chg=73" >> "$LOG_FILE"
            sed -i 's/^chg=.*/chg=73/' "$BOOT_FLAG"
            exit 0
        else
            echo "[DVSSTART] dvsstart.sh failed → retrying in 10s" >> "$LOG_FILE"
        fi
    else
        echo "[DVSSTART] Internet not ready → retrying in 10s" >> "$LOG_FILE"
    fi
    sleep 10
done
