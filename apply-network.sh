#!/bin/bash

# /usr/local/bin/apply-network.sh

CONFIG_FILE="/boot/firmware/network.txt"
WPA_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"
DHCPCD_CONF="/etc/dhcpcd.conf"

# 파일이 없으면 종료
[ -f "$CONFIG_FILE" ] || exit 0

# 변수 초기화
ETH_IP=""
ETH_GW=""
ETH_DNS=""
WIFI_IP=""
WIFI_GW=""
WIFI_DNS=""
WIFI_SSID=""
WIFI_PW=""

current_section=""

# config 파싱
while IFS='=' read -r key value; do
    key=$(echo "$key" | tr -d ' ')
    value=$(echo "$value" | sed 's/^ *//' | sed 's/ *$//')

    case "$key" in
        \[*\])
            current_section="${key//[\[\]]/}"
            ;;
        ip)
            if [ "$current_section" == "Ethernet" ]; then
                ETH_IP="$value"
            elif [ "$current_section" == "Wifi" ]; then
                WIFI_IP="$value"
            fi
            ;;
        gateway)
            if [ "$current_section" == "Ethernet" ]; then
                ETH_GW="$value"
            elif [ "$current_section" == "Wifi" ]; then
                WIFI_GW="$value"
            fi
            ;;
        dns)
            if [ "$current_section" == "Ethernet" ]; then
                ETH_DNS="$value"
            elif [ "$current_section" == "Wifi" ]; then
                WIFI_DNS="$value"
            fi
            ;;
        ssid)
            WIFI_SSID=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')
            ;;
        password)
            WIFI_PW=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')
            ;;
    esac
done < "$CONFIG_FILE"

# Wi-Fi 설정
cat <<EOF | sudo tee "$WPA_CONF" > /dev/null
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=KR

network={
    ssid="$WIFI_SSID"
    psk="$WIFI_PW"
}
EOF

chmod 600 "$WPA_CONF"

# rfkill 해제
rfkill unblock wifi

# dhcpcd.conf 설정
sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak

{
    echo ""
    echo "# Ethernet 설정"
    echo "interface eth0"
    echo "static ip_address=${ETH_IP}/24"
    echo "static routers=${ETH_GW}"
    echo "static domain_name_servers=${ETH_DNS}"

    echo ""
    echo "# Wi-Fi 설정"
    echo "interface wlan0"
    echo "static ip_address=${WIFI_IP}/24"
    echo "static routers=${WIFI_GW}"
    echo "static domain_name_servers=${WIFI_DNS}"
} | sudo tee -a "$DHCPCD_CONF" > /dev/null
