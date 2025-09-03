#!/bin/bash

# do-it-all.sh - Complete MeshCore device setup script
# Usage: ./do-it-all.sh <remote_host_or_ip> [user] [dest_dir]

SCRIPT_DIR="$(dirname "$0")"

echo "MeshCore Complete Setup Script"
echo "============================="
echo ""

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <remote_host_or_ip> [user] [dest_dir]"
    echo "Example: $0 192.168.1.100"
    echo "Example: $0 raspberrypi.local pi /home/pi/flasher"
    echo ""
    echo "For password authentication, set SSHPASS environment variable:"
    echo "SSHPASS='your_password' $0 192.168.1.100"
    exit 1
fi

REMOTE_HOST="$1"
REMOTE_USER="${2:-pi}"
REMOTE_DEST_DIR="${3:-~/meshcore-pi-rak-flasher}"

echo "Target: $REMOTE_USER@$REMOTE_HOST:$REMOTE_DEST_DIR"
echo ""

# Step 1: Sync files to remote
echo "=== Step 1: Syncing files to remote PC ==="
"$SCRIPT_DIR/sync-remote.sh" "$REMOTE_HOST" "$REMOTE_USER" "$REMOTE_DEST_DIR"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to sync files to remote PC"
    exit 1
fi

echo ""
echo "=== Step 2: Flashing firmware on remote PC ==="

# Check if SSHPASS is set for consistent authentication
if [ -n "$SSHPASS" ]; then
    SSH_CMD="sshpass -e ssh"
else
    SSH_CMD="ssh"
fi

# Step 2: Run flasher on remote
$SSH_CMD "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_DEST_DIR && ./flasher.sh"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to flash firmware"
    exit 1
fi

echo ""
echo "=== Step 3: Configuring repeater on remote PC ==="

# Step 3: Run configuration on remote
$SSH_CMD "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_DEST_DIR && python3 configure-repeater.py"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS: Complete MeshCore setup finished!"
    echo ""
    echo "Device has been:"
    echo "  1. ✅ Files synced to remote PC"
    echo "  2. ✅ Firmware flashed"
    echo "  3. ✅ Repeater configured and rebooted"
    echo ""
    echo "Your MeshCore device is now ready!"
else
    echo ""
    echo "⚠️  WARNING: Configuration step failed, but flashing succeeded"
    echo ""
    echo "You may need to manually configure the device using:"
    echo "ssh $REMOTE_USER@$REMOTE_HOST 'cd $REMOTE_DEST_DIR && python3 configure-repeater.py'"
fi