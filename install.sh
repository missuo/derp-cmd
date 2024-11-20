#!/bin/bash
###
 # @Author: Vincent Yang
 # @Date: 2024-11-19 23:02:30
 # @LastEditors: Vincent Yang
 # @LastEditTime: 2024-11-19 23:13:36
 # @FilePath: /derp-cmd/install.sh
 # @Telegram: https://t.me/missuo
 # @GitHub: https://github.com/missuo
 # 
 # Copyright © 2024 by Vincent, All Rights Reserved. 
### 

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if port 443 is available
check_port() {
    if netstat -tuln | grep -q ":443 "; then
        echo "Error: Port 443 is already in use. Please free up the port first."
        exit 1
    fi
}

# Check required commands
for cmd in curl jq systemctl netstat; do
    if ! command_exists "$cmd"; then
        echo "Error: Required command '$cmd' not found. Please install it first."
        exit 1
    fi
done

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root"
    exit 1
fi

# Check port 443 availability
check_port

# Get latest release tag
echo "Fetching latest release information..."
LATEST_TAG=$(curl -s "https://api.github.com/repos/missuo/derp-cmd/releases/latest" | jq -r .tag_name)

if [ -z "$LATEST_TAG" ]; then
    echo "Error: Could not fetch latest release tag"
    exit 1
fi

echo "Latest version: $LATEST_TAG"

read -p "Please enter your hostname (e.g., derp.example.com): " HOSTNAME

# Download binary
echo "Downloading derper binary..."
DOWNLOAD_URL="https://github.com/missuo/derp-cmd/releases/download/$LATEST_TAG/derper-linux-amd64"
if ! curl -L -o /usr/local/bin/derper "$DOWNLOAD_URL"; then
    echo "Error: Failed to download derper binary"
    exit 1
fi

# Set permissions
chmod +x /usr/local/bin/derper

# Create systemd service file
cat > /etc/systemd/system/derper.service << EOF
[Unit]
Description=DERP Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/derper --hostname=$HOSTNAME
WorkingDirectory=/usr/local/bin
User=root
Restart=always
RestartSec=10
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
systemctl daemon-reload
systemctl enable derper
systemctl start derper

echo "Installation completed successfully!"
echo "Derper service has been installed and started."
echo "You can check the status with: systemctl status derper"