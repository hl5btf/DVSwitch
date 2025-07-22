#!/bin/bash

BASHRC="/etc/bash.bashrc"

# 추가할 alias 목록
read -r -d '' ALIASES << 'EOF'
alias dv="cd /usr/local/dvs"
alias data="cd /var/lib/dvswitch/dvs"
alias adv="cd /var/lib/dvswitch/dvs/adv"
alias user="cd /var/lib/dvswitch/dvs/adv"
alias lan="cd /var/lib/dvswitch/dvs/lan"
alias tgdb="cd /var/lib/dvswitch/dvs/tgdb"
alias ab="cd /opt/Analog_Bridge"
alias mb="cd /opt/MMDVM_Bridge"
alias ar="cd /opt/Analog_Reflector"
alias log="cd /var/log/dvswitch"
EOF

# 하나씩 확인하며, 기존에 없는 alias만 추가

while read -r line; do
    if ! grep -Fxq "$line" "$BASHRC"; then
        echo "$line" | sudo tee -a "$BASHRC" > /dev/null
    fi
done <<< "$ALIASES"

# 콘솔에서 source /etc/bash.bashrc 를 실행해야 적용됨
