#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires root. Running with sudo..."
  sudo "$0" "$@"
  exit
fi

read -p "Set the path for log file (eg. /home/me/): " LOG_PATH
read -p "Set the path for your system\\'s battery (eg. /sys/class/power_supply/): " BATTERY_PATH

CONFIG_FILE="config"

if [ -f "$CONFIG_FILE" ]; then
    sed -i "s|^LOG_PATH=.*|LOG_PATH=$LOG_PATH|" "$CONFIG_FILE" || echo "LOG_PATH=$LOG_PATH" >> "$CONFIG_FILE"
    sed -i "s|^BATTERY=.*|BATTERY=$BATTERY_PATH|" "$CONFIG_FILE" || echo "BATTERY_PATH=$BATTERY_PATH" >> "$CONFIG_FILE"
else
    echo "LOG_PATH=$LOG_PATH" > "$CONFIG_FILE"
    echo "BATTERY_PATH=$BATTERY_PATH" >> "$CONFIG_FILE"
fi

mv power_monitor.py /usr/local/bin/
chmod +x /usr/local/bin/power_monitor.py
mv power_monitor.service /etc/systemd/system/
systemctl daemon-reload
systemctl start battery_monitor.service
systemctl enable battery_monitor.service

echo "Power monitor is configured and running."
echo "Logs will be available at: $LOG_PATH/power_monitor.log"
