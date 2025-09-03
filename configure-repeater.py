#!/usr/bin/env python3

import serial
import time
import glob
import sys

# Configuration - Edit these values as needed
FREQ = "910.525"
BW = "62.6"
SF = "7"
CR = "5"
TX_POWER = "22"
ADVERT_INTERVAL = "60"
FLOOD_ADVERT_INTERVAL = "3"
NAME = "Repeater-01"
PASSWORD = "meshcore123"

print("MeshCore Repeater Configuration Tool")
print("====================================")

# Find device
devices = glob.glob('/dev/ttyACM*') + glob.glob('/dev/ttyUSB*')
if not devices:
    print("Error: No device found (/dev/ttyACM* or /dev/ttyUSB*)")
    print("Please ensure the repeater device is connected")
    sys.exit(1)

device = devices[0]
print(f"Found device: {device}")
print(f"Configuration:")
print(f"  Name: {NAME}")
print(f"  Password: {PASSWORD}")
print(f"  Frequency: {FREQ} MHz")
print(f"  Bandwidth: {BW} kHz")
print(f"  Spreading Factor: {SF}")
print(f"  Coding Rate: {CR}")
print(f"  TX Power: {TX_POWER} dBm")
print(f"  Advertisement Interval: {ADVERT_INTERVAL} minutes")
print(f"  Flood Advertisement Interval: {FLOOD_ADVERT_INTERVAL} hours")
print()

def send_command(ser, cmd):
    print(f"Sending: {cmd}")
    ser.write(f"{cmd}\r\n".encode())
    ser.flush()
    time.sleep(1)
    
    response = ser.read_all().decode('utf-8', errors='ignore')
    if response.strip():
        print(f"Response: {response.strip()}")
    print()

try:
    with serial.Serial(device, 115200, timeout=2) as ser:
        time.sleep(0.5)
        
        print("Starting configuration...")
        print()
        
        # Set device name
        send_command(ser, f"set name {NAME}")
        
        # Set password
        send_command(ser, f"password {PASSWORD}")
        
        # Set clock to current system time
        current_time = int(time.time())
        send_command(ser, f"time {current_time}")
        
        # Set frequency
        send_command(ser, f"set freq {FREQ}")
        
        # Set radio parameters
        send_command(ser, f"set radio {FREQ},{BW},{SF},{CR}")
        
        # Set TX power
        send_command(ser, f"set tx {TX_POWER}")
        
        # Set advertisement intervals
        send_command(ser, f"set advert.interval {ADVERT_INTERVAL}")
        send_command(ser, f"set flood.advert.interval {FLOOD_ADVERT_INTERVAL}")
        
        print("Configuration complete! Rebooting device...")
        send_command(ser, "reboot")
        
        print("Device rebooted. Waiting 5 seconds for restart...")

except Exception as e:
    # Ignore I/O errors after reboot - this is expected when device disconnects
    if "Input/output error" in str(e) or "[Errno 5]" in str(e):
        print("Device rebooted successfully (connection closed as expected)")
    else:
        print(f"Error: {e}")
        sys.exit(1)

# Wait for device to reboot and reconnect
time.sleep(5)

print("Reconnecting to send advertisement...")
try:
    with serial.Serial(device, 115200, timeout=2) as ser:
        time.sleep(1)  # Allow device to settle
        
        print("Sending advertisement...")
        send_command(ser, "advert")
        
        print("Configuration applied successfully!")

except Exception as e:
    print(f"Warning: Could not send advertisement after reboot: {e}")
    print("Device configuration was successful, but final advertisement failed")