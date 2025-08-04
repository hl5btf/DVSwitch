#!/bin/bash

# /usr/local/bin/apply-network.sh

CONFIG_FILE="/boot/firmware/network.txt"
WIFI_CONF="/var/lib/iwd"
DNS_SERVERS="8.8.8.8 1.1.1.1"

[ -f "$CONFIG_FILE" ] || exit 0

ETH_IP=""; ETH_GW=""
WIFI_IP=""; WIFI_GW=""; WIFI_SSID=""; WIFI_PW=""

section=""
while IFS='=' read -r key value; do
    key=$(echo "$key" | tr -d ' ')
    value=$(echo "$value" | sed 's/^ *//' | sed 's/ *$//')
    [[ "$value" =~ ^\".*\"$ ]] && value="${value:1:-1}"

    case "$key" in
        "[Ethernet]") section="eth" ;;
        "[Wifi]") section="wifi" ;;
        ip)
            [[ "$section" == "eth" ]] && ETH_IP="$value"
            [[ "$section" == "wifi" ]] && WIFI_IP="$value"
            ;;
        gateway)
            [[ "$section" == "eth" ]] && ETH_GW="$value"
            [[ "$section" == "wifi" ]] && WIFI_GW="$value"
            ;;
        ssid) WIFI_SSID="$value" ;;
        password) WIFI_PW="$value" ;;
    esac
done < "$CONFIG_FILE"

# 공통 DNS 설정 적용 (resolv.conf)
rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# 유선 설정
if [ -n "$ETH_IP" ] && [ -n "$ETH_GW" ]; then
    ip link set dev eth0 up
    ip addr flush dev eth0
    ip addr add "$ETH_IP/24" dev eth0
    ip route del default || true
    ip route add default via "$ETH_GW" dev eth0
fi

# 무선 설정
if [ -n "$WIFI_SSID" ] && [ -n "$WIFI_PW" ]; then
    PSK_FILE="$WIFI_CONF/${WIFI_SSID}.psk"
    NETWORK_FILE="$WIFI_CONF/${WIFI_SSID}.network"

    cat <<EOF > "$PSK_FILE"
[Security]
PreSharedKey=$WIFI_PW

[Settings]
AutoConnect=true
EOF

    cat <<EOF > "$NETWORK_FILE"
[IPv4]
Address=$WIFI_IP
Gateway=$WIFI_GW
DNS=$DNS_SERVERS
EOF

    chown iwd:iwd "$PSK_FILE" "$NETWORK_FILE"
    chmod 600 "$PSK_FILE" "$NETWORK_FILE"

    systemctl restart iwd
    sleep 10

    ip addr flush dev wlan0
    ip addr add "$WIFI_IP/24" dev wlan0
    ip route del default || true
    ip route add default via "$WIFI_GW" dev wlan0
fi

