# Power Monitor
A simple daemon for battery-operated linux boxes that polls the power status, and shuts down the machine if the battery falls below the defined threshold.

## Usage:
1. Move the script to `/usr/local/bin/` and make it executable
1. Move the service file to `/etc/systemd/system/`
1. Start the service and configure launch on boot:
  ```
  sudo systemctl daemon-reload
  sudo systemctl start battery_monitor.service
  sudo systemctl enable battery_monitor.service
  ```
1. Open the `config` file and set the `LOG_FILE` and `BATTERY_PATH` variables

The `setup.sh` script is provided to perform the above steps.
