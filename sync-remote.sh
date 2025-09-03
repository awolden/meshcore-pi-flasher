#!/bin/bash

# sync-remote.sh - Sync project files to remote PC via SSH

# Default configuration
DEFAULT_USER="pi"
DEFAULT_DEST_DIR="~/meshcore-pi-rak-flasher"
LOCAL_DIR="$(dirname "$0")"

# Parse arguments
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
REMOTE_USER="${2:-$DEFAULT_USER}"
REMOTE_DEST_DIR="${3:-$DEFAULT_DEST_DIR}"

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

# Download packages for offline installation
echo "Downloading packages for offline installation..."
OFFLINE_DIR="$LOCAL_DIR/offline_packages"
rm -rf "$OFFLINE_DIR"
mkdir -p "$OFFLINE_DIR"

# Download get-pip.py
curl -s https://bootstrap.pypa.io/get-pip.py -o "$OFFLINE_DIR/get-pip.py"

# Download only adafruit-nrfutil and its dependencies
pip3 download --dest "$OFFLINE_DIR" --no-cache-dir adafruit-nrfutil

if [ $? -ne 0 ]; then
    echo "Error: Failed to download packages"
    exit 1
fi

echo "Packages downloaded for offline installation"

echo "Syncing files to $REMOTE_USER@$REMOTE_HOST:$REMOTE_DEST_DIR..."

# Create destination directory on remote PC
$SSH_CMD "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_DEST_DIR"

# Copy all files from current directory to remote PC
$RSYNC_CMD -avz --progress \
    --exclude='.git' \
    --exclude='.DS_Store' \
    --exclude='*.log' \
    -e "$SSH_CMD" \
    "$LOCAL_DIR/" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DEST_DIR/"

if [ $? -eq 0 ]; then
    echo "Files successfully synced to $REMOTE_USER@$REMOTE_HOST:$REMOTE_DEST_DIR"
    
    # Make scripts executable on remote PC
    $SSH_CMD "$REMOTE_USER@$REMOTE_HOST" "chmod +x $REMOTE_DEST_DIR/*.sh"
    
    # Install pip on remote PC if not available
    echo "Setting up pip on remote PC..."
    $SSH_CMD "$REMOTE_USER@$REMOTE_HOST" "
        if ! python3 -m pip --version >/dev/null 2>&1; then
            echo 'Installing pip...'
            python3 $REMOTE_DEST_DIR/offline_packages/get-pip.py --user --break-system-packages
        else
            echo 'pip already available'
        fi
    "
    
    # Install adafruit-nrfutil from offline directory
    echo "Installing adafruit-nrfutil from offline directory..."
    $SSH_CMD "$REMOTE_USER@$REMOTE_HOST" "
        cd $REMOTE_DEST_DIR/offline_packages
        ~/.local/bin/pip install --no-index --find-links . adafruit-nrfutil --break-system-packages
    "
    
    if [ $? -eq 0 ]; then
        echo "Python packages installed successfully on remote PC"
    else
        echo "Warning: Python package installation failed on remote PC"
    fi
    
    echo "Setup completed on remote PC"
else
    echo "Error: Failed to sync files to remote PC"
    exit 1
fi