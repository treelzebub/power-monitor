#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires root. Running with sudo..."
  sudo "$0" "$@"
  exit
fi

read -p "Set the path for log file (eg. /home/me/): " LOG_PATH

echo "Available power supply paths:"
ls -1 /sys/class/power_supply
read -p "Set the path for your system's battery (eg. /sys/class/power_supply/battery0/): " BATTERY_PATH

CONFIG_FILE="config"
touch config
sed -i "s|^LOG_PATH=.*|LOG_PATH=$LOG_PATH|" "$CONFIG_FILE" || echo "LOG_PATH=$LOG_PATH" >> "$CONFIG_FILE"
sed -i "s|^BATTERY=.*|BATTERY=$BATTERY_PATH|" "$CONFIG_FILE" || echo "BATTERY_PATH=$BATTERY_PATH" >> "$CONFIG_FILE"

mkdir -p /etc/power_monitor/
cp config /etc/power_monitor/
chmod +x power_monitor.py
cp power_monitor.py /usr/local/bin/
cp power_monitor.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable power_monitor.service
systemctl start power_monitor.service

echo "Power monitor is configured and running."
echo "Logs will be available at:" $LOG_PATH "power_monitor.log"
