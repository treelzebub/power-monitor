#!/usr/bin/python3

import os
import time
import subprocess
import psutil
from datetime import datetime


def make_path(path, file_name):
  if path and not path.endswith('/'):
    path += '/'
  return path + file_name

def read_config(file_path):
  config = {}

  with open(file_path, 'r') as f:
    for line in f:
      line = line.strip()
      if not line or line.startswith('#'):
        continue
      key, value = line.split('=', 1)
      config[key.strip()] = value.strip()
    
    return config

POLL_INTERVAL = 600

CONFIG = read_config('/etc/power_monitor/config')
LOG_PATH = CONFIG.get('LOG_PATH')
LOG = make_path(LOG_PATH, 'power_monitor.log')
CHARGE_THRESHOLD = CONFIG.get('CHARGE_THRESHOLD')

def log(message):
    timestamp = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    with open(LOG, "a") as log_file:
        log_file.write(f"[{timestamp}] - {message}\n")

def read_file(file_path):
  try:
    with open(file_path, "r") as file:
      return file.readline().strip()
  except Exception as e:
    log(f"Error reading {file_path}: {e}")
    return None

def get_battery_status():
  battery = psutil.sensors_battery()
  plugged = battery.power_plugged if battery is not None else False

  if battery:
      charge = battery.percent
      log(f"Polled power. Plugged in: {plugged}; Battery Capacity: {charge}%")
      return charge
  else:
      log("Polled power. Battery information is unavailable.")
      return None

def shutdown():
  log("Battery is below 20%. Shutting down in 60 seconds...")
  subprocess.run(["shutdown", "-h", "+60"]) 

def main():
  while True:
    charge = get_battery_status()

    if charge is not None and charge < CHARGE_THRESHOLD:
      shutdown()
      break
        
    time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
  main()
