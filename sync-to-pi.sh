#!/bin/bash

# sync-to-pi.sh - Sync project files to Raspberry Pi via SSH

# Default configuration
DEFAULT_USER="pi"
DEFAULT_DEST_DIR="/home/pi/meshcore-pi-rak-flasher"
LOCAL_DIR="$(dirname "$0")"

# Parse arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <pi_host_or_ip> [user] [dest_dir]"
    echo "Example: $0 192.168.1.100"
    echo "Example: $0 raspberrypi.local pi /home/pi/flasher"
    echo ""
    echo "For password authentication, set SSHPASS environment variable:"
    echo "SSHPASS='your_password' $0 192.168.1.100"
    exit 1
fi

PI_HOST="$1"
PI_USER="${2:-$DEFAULT_USER}"
PI_DEST_DIR="${3:-$DEFAULT_DEST_DIR}"

# Check if password authentication is needed
if [ -n "$SSHPASS" ]; then
    # Check if sshpass is installed
    if ! command -v sshpass &> /dev/null; then
        echo "Error: sshpass not found. Install it with:"
        echo "  macOS: brew install hudochenkov/sshpass/sshpass"
        echo "  Ubuntu/Debian: sudo apt-get install sshpass"
        exit 1
    fi
    SSH_CMD="sshpass -e ssh"
    RSYNC_CMD="sshpass -e rsync"
else
    SSH_CMD="ssh"
    RSYNC_CMD="rsync"
fi

echo "Syncing files to $PI_USER@$PI_HOST:$PI_DEST_DIR..."

# Create destination directory on Pi
$SSH_CMD "$PI_USER@$PI_HOST" "mkdir -p $PI_DEST_DIR"

# Copy all files from current directory to Pi
$RSYNC_CMD -avz --progress \
    --exclude='.git' \
    --exclude='.DS_Store' \
    --exclude='*.log' \
    -e "$SSH_CMD" \
    "$LOCAL_DIR/" "$PI_USER@$PI_HOST:$PI_DEST_DIR/"

if [ $? -eq 0 ]; then
    echo "Files successfully synced to $PI_USER@$PI_HOST:$PI_DEST_DIR"
    
    # Make scripts executable on Pi
    $SSH_CMD "$PI_USER@$PI_HOST" "chmod +x $PI_DEST_DIR/*.sh"
    
    echo "Scripts made executable on Pi"
else
    echo "Error: Failed to sync files to Pi"
    exit 1
fi