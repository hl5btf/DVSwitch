#!/bin/bash

# /usr/local/bin/dvsstart-runner.sh

BOOT_FLAG="/boot/firmware/dvsconfig.txt"
LOG_FILE="/var/log/dvswitch/dvsstart-run.log"

echo "[DVSSTART] Service started at $(date)" >> "$LOG_FILE"

# 로그 줄 수가 100줄 넘으면 최근 100줄만 유지
MAX_LINES=100
TOTAL_LINES=$(wc -l < "$LOG_FILE")

if [ "$TOTAL_LINES" -gt "$MAX_LINES" ]; then
    tail -n $MAX_LINES "$LOG_FILE" > "${LOG_FILE}.tmp"
    mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi


# ✅ /boot 마운트 될 때까지 대기 (무제한)
while [ ! -f "$BOOT_FLAG" ]; do
  echo "[DVSSTART] Waiting for /boot mount..." >> "$LOG_FILE"
  sleep 2
done
echo "[DVSSTART] /boot detected!" >> "$LOG_FILE"

# 실행 여부 확인
source "$BOOT_FLAG"
RESPONSE="${chg:-0}"

if [ "$RESPONSE" != "1" ]; then
  echo "[DVSSTART] Skipping (chg=$RESPONSE)" >> "$LOG_FILE"
  exit 0
fi

echo "[DVSSTART] chg=1 detected → Starting dvsstart.sh with retry loop..." >> "$LOG_FILE"

while true; do
  if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "[DVSSTART] Internet OK → running dvsstart.sh" >> "$LOG_FILE"
    /etc/dvsstart.sh
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


