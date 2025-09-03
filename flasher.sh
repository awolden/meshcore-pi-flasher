#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

echo "NRF Board Flasher for WisBlock RAK"
echo "=================================="

ZIP_FILE=$(find "$SCRIPT_DIR" -name "*.zip" | head -1)

if [ -z "$ZIP_FILE" ]; then
    echo "Error: No .zip file found in $SCRIPT_DIR"
    echo "Please provide a .zip package file for adafruit-nrfutil"
    exit 1
fi

echo "Found firmware package: $(basename "$ZIP_FILE")"

USB_DEVICE=$(lsusb | grep -i "nordic\|rak\|wisblock\|adafruit" | head -1)

if [ -z "$USB_DEVICE" ]; then
    echo "Error: No NRF/RAK device found via lsusb"
    exit 1
fi

echo "Found device: $USB_DEVICE"

# Use system-installed adafruit-nrfutil
echo "Using system-installed adafruit-nrfutil"

for device in /dev/ttyACM* /dev/ttyUSB*; do
    if [ -e "$device" ]; then
        echo "Flashing firmware via $device..."
        ~/.local/bin/adafruit-nrfutil --verbose dfu serial --package "$ZIP_FILE" --port "$device" --baudrate 1000000 --singlebank --touch 1200
        
        if [ $? -eq 0 ]; then
            echo "Flash completed successfully!"
            echo "Waiting for device to reboot..."
            sleep 3
            exit 0
        else
            echo "Flash failed on $device"
        fi
    fi
done

echo "Error: No suitable device found"
exit 1