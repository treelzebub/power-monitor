# Power Monitor
A simple daemon for battery-operated linux boxes that polls the power status, and shuts down the machine if the battery falls below the defined threshold.

## Requirements:
* pyenv, pip, psutil

## Usage:
1. Move the script to `/usr/local/bin/` and make it executable
1. Move the service file to `/etc/systemd/system/`
1. Start the service and configure launch on boot:
  ```
  sudo systemctl daemon-reload
  sudo systemctl start battery_monitor.service
  sudo systemctl enable battery_monitor.service
  ```
1. Create a configuration file at `/etc/power_monitor/config` and set the `LOG_FILE` and `CHARGE_THRESHOLD` variables

The `setup.sh` script is provided to perform the above steps.
