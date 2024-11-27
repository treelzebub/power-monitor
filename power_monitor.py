#!/usr/bin/python3

import os
import time
import subprocess
import psutil
from datetime import datetime

CAPACITY_THRESHOLD = 20
POLL_INTERVAL = 60 * 10

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

CONFIG = read_config('config')
LOG_PATH = CONFIG.get('LOG_PATH')
LOG = make_path(LOG_PATH, 'power_monitor.log')
BATTERY = CONFIG.get('BATTERY_PATH')
STATUS = os.path.join(BATTERY, "status")
CAPACITY = os.path.join(BATTERY, "capacity")

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
  plugged = psutil.sensors_battery().power_plugged
  status = "plugged" if plugged else read_file(STATUS)
  capacity = None

  if not plugged:
    capacity = read_file(CAPACITY)

    try:
      capacity = int(capacity) if capacity_raw is not None else None
    except ValueError:
      log(f"Invalid battery capacity: {capacity}")

    log(f"Polled power. Status: {status}; Battery Capacity: {capacity}")
    return status, capacity

def shutdown():
  log("Battery is below 20%. Shutting down...")
  subprocess.run(["shutdown", "-h", "now"])

def main():
  while True:
    status, capacity = get_battery_status()

    if status == "Discharging" and capacity is not None and capacity < CAPACITY_THRESHOLD:
      shutdown()
      break

      time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
  main()
