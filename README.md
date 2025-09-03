# MeshCore Remote RAK Flasher

Flash and configure MeshCore firmware on NRF boards via a remote airgapped host.

## Quick Start

1. **Download firmware** - Get the latest `.zip` firmware from [meshcore.co.uk](https://meshcore.co.uk) and place it in this directory

2. **Edit configuration** - Update the values at the top of `configure-repeater.py` for your device

3. **Run the complete setup**:
   ```bash
   ./do-it-all.sh <remote_host_or_ip> <remote_user>
   ```

That's it! This will sync files, flash firmware, and configure the repeater automatically.

## Manual Steps

If you prefer to run each step manually:

### 1. Sync to Remote
```bash
./sync-remote.sh <remote_host_or_ip>
```

### 2. Flash Firmware
```bash
# On remote PC
./flasher.sh
```

### 3. Configure Repeater
```bash  
# On remote PC
python3 configure-repeater.py
```

## Configuration

Edit values at the top of `configure-repeater.py`:
- `NAME`: Device name (default: "Repeater-01")
- `PASSWORD`: Device password (default: "meshcore123")  
- `FREQ`: Radio frequency (default: "910.525")
- `BW`: Bandwidth (default: "62.6")
- `SF`: Spreading factor (default: "7") 
- `CR`: Coding rate (default: "5")
- `TX_POWER`: TX power in dBm (default: "22")
- `ADVERT_INTERVAL`: Ad interval in minutes (default: "60")
- `FLOOD_ADVERT_INTERVAL`: Flood ad interval in hours (default: "3")

## Password Authentication

For password auth, set `SSHPASS`:
```bash
SSHPASS='password' ./do-it-all.sh 192.168.1.100
```

Requires `sshpass`:
- macOS: `brew install hudochenkov/sshpass/sshpass`  
- Linux: `sudo apt install sshpass`

## What It Does

1. Downloads `adafruit-nrfutil` and dependencies offline
2. Copies everything to remote PC via SSH
3. Installs Python packages on remote (airgapped)
4. Flashes firmware via serial
5. Configures radio settings, device name, and password
6. Sends advertisement and reboots device
