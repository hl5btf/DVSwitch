#!/bin/bash

# /usr/local/bin/dvsstart-runner.sh

# /etc/systemd/system/dvsstart.service에서 dvsstart-runner.sh를 실행할때 root로 실행하기 때문에 아래의 스크립트에는 sudo를 사용할 필요없음.

BOOT_FLAG="/boot/firmware/dvsconfig.txt"
LOG_FILE="/var/log/dvswitch/dvsstart-run.log"
TMP_FILE="/var/log/dvswitch/dvsstart-run.trim"
DVS_SCRIPT="/etc/dvsstart.sh"
DVS_URL="https://raw.githubusercontent.com/hl5btf/DVSwitch/main/dvsstart.sh"
MAX_LINES=100

# 로그 파일 생성 및 초기 기록
mkdir -p "$(dirname "$LOG_FILE")"
[ -f "$LOG_FILE" ] || touch "$LOG_FILE"
echo "" >> "$LOG_FILE"
echo "[_RUNNER_] $(date) Service started =============================" >> "$LOG_FILE"

# 로그 줄 수 제한
tail -n "$MAX_LINES" "$LOG_FILE" > "$TMP_FILE" && cp "$TMP_FILE" "$LOG_FILE"

# /boot 마운트될 때까지 대기
while [ ! -f "$BOOT_FLAG" ]; do
    echo "[_RUNNER_] $(date +%T) Waiting for /boot mount..." >> "$LOG_FILE"
    sleep 2
done
echo "[_RUNNER_] $(date +%T) /boot detected!" >> "$LOG_FILE"

# 설정값 확인
source "$BOOT_FLAG"
CHG="${chg:-0}"
if [ "$CHG" != "1" ]; then
    echo "[_RUNNER_] $(date +%T) Skipping (dvsconfig.txt - chg=$CHG)" >> "$LOG_FILE"
    dvsstart_exit=yes
fi

CALLSIGN="${callsign:-HL1AAA}"
if [ "$CALLSIGN" = "HL1AAA" ]; then
    echo "[_RUNNER_] $(date +%T) Skipping (dvsconfig.txt - callsign=$CALLSIGN)" >> "$LOG_FILE"
    dvsstart_exit=yes
fi

echo "[_RUNNER_] $(date +%T) chg=1 detected → Starting dvsstart.sh with retry loop..." >> "$LOG_FILE"


if [ "$dvsstart_exit" != "yes" ]; then
# 인터넷 연결 확인 후 dvsstart.sh 설치 및 실행
while true; do
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        echo "[_RUNNER_] $(date +%T) Internet OK → download and running dvsstart.sh" >> "$LOG_FILE"

	# 1. 다운로드
        if ! wget -q -O "$DVS_SCRIPT" "$DVS_URL"; then
            echo "[_RUNNER_] $(date +%T) Failed to download dvsstart.sh" >> "$LOG_FILE"
            exit 1
        fi
        echo "[_RUNNER_] $(date +%T) Downloaded dvsstart.sh" >> "$LOG_FILE"

	# 2. 실행 권한
        if ! chmod +x "$DVS_SCRIPT"; then
            echo "[_RUNNER_] $(date +%T) Failed to chmod dvsstart.sh" >> "$LOG_FILE"
            exit 1
        fi
        echo "[_RUNNER_] $(date +%T) Made dvsstart.sh executable" >> "$LOG_FILE" 

        # 3. 실행
        if "$DVS_SCRIPT"; then
            echo "[_RUNNER_] $(date +%T) back to dvsstart-runner.sh and finish" >> "$LOG_FILE" 
            sed -i 's/^chg=.*/chg=73/' "$BOOT_FLAG"
            exit 0
	else
            echo "[_RUNNER_] $(date +%T) dvsstart.sh failed → retrying in 10s" >> "$LOG_FILE"
        fi
    else
        echo "[_RUNNER_] $(date +%T) Internet not ready → retrying in 10s" >> "$LOG_FILE"
    fi
    sleep 10
done
fi

# dvsmu_upgrade.sh
# 아래의 내용은 이미지 제작후의 변경내용 반영하기 위한 초기 업그레이드임. 1회 실행후에는 지우게 됨 
if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        file=dvsmu_upgrade.sh
        sudo wget -O /tmp/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file > /dev/null 2>&1
        sudo chmod +x /tmp/$file
        sudo /tmp/$file call_from_dvsstart
        sleep 1
        sudo rm /tmp/$file
fi

# ---[ 1회 실행 후 자기 자신 정리: 백업 없이, 마커 줄 포함 삭제 ]---
SELF="${BASH_SOURCE[0]:-$0}"
MARK_RE='^[[:space:]]*# dvsmu_upgrade\.sh[[:space:]]*$'  # 마커 패턴(공백 허용)
DIR="$(dirname "$SELF")"
TMP="$(mktemp "$DIR/.prune.XXXXXX")" || exit 0

# 마커 줄 위치(첫 매칭) 찾기
line_num="$(grep -n -E "$MARK_RE" "$SELF" | head -n1 | cut -d: -f1 || true)"

if [[ -n "$line_num" ]]; then
  # 마커 '위'까지만 남기기 (line_num이 1이면 head -n 0 → 빈 파일)
  if [[ -w "$DIR" && -w "$SELF" ]]; then
    head -n $((line_num-1)) "$SELF" > "$TMP" \
      && chown --reference="$SELF" "$TMP" \
      && chmod --reference="$SELF" "$TMP" \
      && mv -f "$TMP" "$SELF" || { rm -f "$TMP"; exit 0; }
  else
    sudo sh -c "
      head -n $((line_num-1)) '$SELF' > '$TMP' &&
      chown --reference='$SELF' '$TMP' &&
      chmod --reference='$SELF' '$TMP' &&
      mv -f '$TMP' '$SELF'
    " || { rm -f "$TMP"; exit 0; }
  fi
else
  rm -f "$TMP"
fi
# --------------------------------------------------------------------

