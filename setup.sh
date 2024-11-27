#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires root. Running with sudo..."
  sudo "$0" "$@"
  exit
fi

PYTHON3_PATH=$(pyenv which python3)
PIP_PATH=$(pyenv which pip)

if [ -z "$PYTHON3_PATH" ] || [ -z "$PIP_PATH" ]; then
  echo "python or pip not found. Bailing."
  exit 1
fi

export PATH=$PYTHON3_PATH:$PIP_PATH:$PATH

read -p "Set the path for log file (eg. /home/me/): " LOG_PATH
read -p "Shutdown when the battery falls below what threshold: " CHARGE_THRESHOLD

CONFIG_FILE="config"
touch config
sed -i "s|^LOG_PATH=.*|LOG_PATH=$LOG_PATH|" "$CONFIG_FILE" || echo "LOG_PATH=$LOG_PATH" >> "$CONFIG_FILE"
sed -i "s|^CHARGE_THRESHOLD=.*|CHARGE_THRESHOLD=$CHARGE_THRESHOLD|" "$CONFIG_FILE" || echo "CHARGE_THRESHOLD=$CHARGE_THRESHOLD" >> "$CONFIG_FILE"

echo "Installing dependencies..."
python -m pip install -r requirements.txt

echo "Configuring Power Monitor service..."
mkdir -p /etc/power_monitor/
mv config /etc/power_monitor/
chmod +x power_monitor.py
cp power_monitor.py /usr/local/bin/
chown root:root /usr/local/bin/power_monitor.py
cp power_monitor.service /etc/systemd/system/
systemctl daemon-reload
systemctl start power_monitor.service
systemctl enable power_monitor.service

sleep 2

service_status=$(systemctl is-active power_monitor.service)
if [[ "$service_status" == "active" ]]; then
  echo "Power monitor is configured and running."
  echo "Logs will be available at: ${LOG_PATH%/}/power_monitor.log"
  exit 0
else
  echo "Something went wrong. journalctl says:"
  journalctl -u power_monitor.service -f
  exit 1
fi
