#!/bin/bash

# /usr/local/bin/apply-network.sh

CONFIG_FILE="/boot/firmware/network.txt"
DNS_SERVERS="8.8.8.8 1.1.1.1"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "[apply-network] No /boot/firmware/network.txt found. Skipping..."
  exit 0
fi

# 값 읽기
ETH_IP=$(awk -F= "/\\[Ethernet\\]/ {f=1;next} /\\[/{f=0} f && /ip=/ {print \$2}" "$CONFIG_FILE" | tr -d " ")
ETH_GW=$(awk -F= "/\\[Ethernet\\]/ {f=1;next} /\\[/{f=0} f && /gateway=/ {print \$2}" "$CONFIG_FILE" | tr -d " ")

WIFI_SSID=$(awk -F= "/\\[Wifi\\]/ {f=1;next} /\\[/{f=0} f && /ssid=/ {print \$2}" "$CONFIG_FILE" | tr -d " ")
WIFI_PASS=$(awk -F= "/\\[Wifi\\]/ {f=1;next} /\\[/{f=0} f && /password=/ {print \$2}" "$CONFIG_FILE" | tr -d " ")
WIFI_IP=$(awk -F= "/\\[Wifi\\]/ {f=1;next} /\\[/{f=0} f && /ip=/ {print \$2}" "$CONFIG_FILE" | tr -d " ")
WIFI_GW=$(awk -F= "/\\[Wifi\\]/ {f=1;next} /\\[/{f=0} f && /gateway=/ {print \$2}" "$CONFIG_FILE" | tr -d " ")

echo "[apply-network] Applying settings from /boot/firmware/network.txt..."

# Ethernet 설정
if [ -n "$ETH_IP" ] && [ -n "$ETH_GW" ]; then
  echo "[apply-network] Setting static IP for eth0: $ETH_IP"
  nmcli con mod "Wired connection 1" ipv4.addresses "$ETH_IP/24"
  nmcli con mod "Wired connection 1" ipv4.gateway "$ETH_GW"
  nmcli con mod "Wired connection 1" ipv4.dns "$DNS_SERVERS"
  nmcli con mod "Wired connection 1" ipv4.method manual
  nmcli con up "Wired connection 1"
else
  echo "[apply-network] Using DHCP for eth0"
  nmcli con mod "Wired connection 1" ipv4.method auto
  nmcli con up "Wired connection 1"
fi

# Wi-Fi 설정
if [ -n "$WIFI_SSID" ]; then
  echo "[apply-network] Configuring Wi-Fi: $WIFI_SSID"
  nmcli connection delete "$WIFI_SSID" 2>/dev/null
  nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASS"

  if [ -n "$WIFI_IP" ] && [ -n "$WIFI_GW" ]; then
    echo "[apply-network] Setting static IP for Wi-Fi: $WIFI_IP"
    nmcli con mod "$WIFI_SSID" ipv4.addresses "$WIFI_IP/24"
    nmcli con mod "$WIFI_SSID" ipv4.gateway "$WIFI_GW"
    nmcli con mod "$WIFI_SSID" ipv4.dns "$DNS_SERVERS"
    nmcli con mod "$WIFI_SSID" ipv4.method manual
    nmcli con up "$WIFI_SSID"
  else
    echo "[apply-network] Using DHCP for Wi-Fi"
    nmcli con mod "$WIFI_SSID" ipv4.method auto
    nmcli con up "$WIFI_SSID"
  fi
else
  echo "[apply-network] No Wi-Fi SSID provided. Skipping Wi-Fi config."
fi
