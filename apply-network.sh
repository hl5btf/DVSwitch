#!/bin/bash
CONFIG_FILE="/boot/firmware/network.txt"
DNS_SERVERS="8.8.8.8 1.1.1.1"

# 파일이 없으면 종료
[ -f "$CONFIG_FILE" ] || exit 0

# 파일 파싱
ETH_IP=""
ETH_GW=""
WIFI_IP=""
WIFI_GW=""
WIFI_SSID=""
WIFI_PW=""

current_section=""

while IFS='=' read -r key value; do
    key=$(echo "$key" | tr -d ' ')
    value=$(echo "$value" | sed 's/^ *//' | sed 's/ *$//' | tr -d '"')

    case "$key" in
        \[*\])
            current_section=$(echo "$key" | tr -d '[]')
            ;;
        ip)
            if [ "$current_section" = "Ethernet" ]; then
                ETH_IP="$value"
            elif [ "$current_section" = "Wifi" ]; then
                WIFI_IP="$value"
            fi
            ;;
        gateway)
            if [ "$current_section" = "Ethernet" ]; then
                ETH_GW="$value"
            elif [ "$current_section" = "Wifi" ]; then
                WIFI_GW="$value"
            fi
            ;;
        ssid)
            WIFI_SSID="$value"
            ;;
        password)
            WIFI_PW="$value"
            ;;
    esac
done < "$CONFIG_FILE"

# 유선 설정
if [ -n "$ETH_IP" ] && [ -n "$ETH_GW" ]; then
    nmcli con delete "ethernet-static" >/dev/null 2>&1
    nmcli con add type ethernet ifname eth0 con-name "ethernet-static" \
        ipv4.method manual \
        ipv4.addresses "$ETH_IP/24" \
        ipv4.gateway "$ETH_GW" \
        ipv4.dns "$DNS_SERVERS" \
        connection.autoconnect yes
fi

# 무선 설정
if [ -n "$WIFI_SSID" ] && [ -n "$WIFI_PW" ] && [ -n "$WIFI_IP" ] && [ -n "$WIFI_GW" ]; then
    nmcli con delete "$WIFI_SSID" >/dev/null 2>&1
    nmcli dev wifi connect "$WIFI_SSID" password "$WIFI_PW" ifname wlan0 name "$WIFI_SSID"
    nmcli con modify "$WIFI_SSID" \
        ipv4.method manual \
        ipv4.addresses "$WIFI_IP/24" \
        ipv4.gateway "$WIFI_GW" \
        ipv4.dns "$DNS_SERVERS" \
        connection.autoconnect yes
fi

