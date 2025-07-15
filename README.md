# Meshcore Pi RAK Flasher

A tool for flashing DFU-based NRF boards remotely on a Raspberry Pi.

## Usage

### Sync Files to Pi

Use the `sync-to-pi.sh` script to copy all project files to your Raspberry Pi:

```bash
./sync-to-pi.sh <pi_host_or_ip> [user] [dest_dir]
```

Examples:
```bash
# Basic usage (uses default user 'pi' and destination '/home/pi/meshcore-pi-rak-flasher')
./sync-to-pi.sh 192.168.1.100

# With local hostname
./sync-to-pi.sh raspberrypi.local

# Custom user and destination
./sync-to-pi.sh 192.168.1.100 myuser /home/myuser/flasher

# With password authentication
SSHPASS='your_password' ./sync-to-pi.sh 192.168.1.100
```

**Password Authentication**: If you need password authentication, set the `SSHPASS` environment variable. This requires `sshpass` to be installed:
- macOS: `brew install hudochenkov/sshpass/sshpass`
- Ubuntu/Debian: `sudo apt-get install sshpass`

The script will:
- Create the destination directory on the Pi
- Copy all files using rsync (excluding .git, .DS_Store, and .log files)
- Make shell scripts executable on the Pi

### Download Firmware

Download the latest firmware .zip package from [meshcore.co.uk](https://meshcore.co.uk) and place it in this project directory before syncing to the Pi.

### Flash NRF Board

After syncing files to the Pi, use the `flasher.sh` script to flash the firmware package to your NRF board:

```bash
# On the Raspberry Pi
./flasher.sh
```

The script will:
- Find the first .zip file in the current directory
- Detect the NRF board (WisBlock RAK)
- Install adafruit-nrfutil if needed
- Flash the firmware directly via serial
- Open a terminal connection for configuration

**Configuration**: After flashing, a terminal connection will open. For available configuration commands, visit: https://github.com/ripplebiz/MeshCore/wiki/Repeater-&-Room-Server-CLI-Reference