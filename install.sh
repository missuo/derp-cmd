#!/bin/bash
###
 # @Author: Vincent Yang
 # @Date: 2024-11-19 23:02:30
 # @LastEditors: Vincent Yang
 # @LastEditTime: 2024-11-20 22:23:56
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

# Function to check if specified port is available
check_port() {
    local port="$1"
    if netstat -tuln | grep -q ":$port "; then
        echo "Error: Port $port is already in use. Please free up the port first."
        exit 1
    fi
}

# Function to extract port number from address string
extract_port() {
    local addr="$1"
    echo "${addr#*:}"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: Please run as root"
        exit 1
    fi
}

# Function to install required packages
install_dependencies() {
    for cmd in curl jq systemctl netstat; do
        if ! command_exists "$cmd"; then
            echo "Start install $cmd"
            apt update -y && apt install -y $cmd
        fi
    done
}

# Function to get latest release tag
get_latest_tag() {
    LATEST_TAG=$(curl -s "https://api.github.com/repos/missuo/derp-cmd/releases/latest" | jq -r .tag_name)
    if [ -z "$LATEST_TAG" ]; then
        echo "Error: Could not fetch latest release tag"
        exit 1
    fi
    echo "$LATEST_TAG"
}

# Function to download and install binary
install_binary() {
    local tag="$1"
    echo "Downloading derper binary..."
    DOWNLOAD_URL="https://github.com/missuo/derp-cmd/releases/download/$tag/derper-linux-amd64"
    if ! curl -L -o /usr/local/bin/derper "$DOWNLOAD_URL"; then
        echo "Error: Failed to download derper binary"
        exit 1
    fi
    chmod +x /usr/local/bin/derper
}

# Function to create systemd service
create_service() {
    local hostname="$1"
    local address="$2"
    cat > /etc/systemd/system/derper.service << EOF
[Unit]
Description=DERP Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/derper --hostname=$hostname -a=$address
WorkingDirectory=/usr/local/bin
User=root
Restart=always
RestartSec=10
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable derper
    systemctl start derper
}

# Function to install DERP server
install() {
    check_root
    install_dependencies
    
    LATEST_TAG=$(get_latest_tag)
    echo "Latest version: $LATEST_TAG"

    read -p "Please enter your hostname (e.g., derp.example.com): " HOSTNAME
    read -p "Please enter the port number (default: 443): " PORT
    
    # Set default port if none provided
    PORT=${PORT:-443}
    ADDRESS=":$PORT"
    
    # Check if port is available
    check_port "$PORT"

    install_binary "$LATEST_TAG"
    create_service "$HOSTNAME" "$ADDRESS"

    echo "Installation completed successfully!"
    echo "Derper service has been installed and started on port $PORT."
    echo "You can check the status with: systemctl status derper"
}

# Function to uninstall DERP server
uninstall() {
    check_root
    
    echo "Stopping and disabling DERP server..."
    systemctl stop derper
    systemctl disable derper

    echo "Removing files..."
    rm -f /usr/local/bin/derper
    rm -f /etc/systemd/system/derper.service
    
    systemctl daemon-reload

    echo "DERP server has been uninstalled successfully!"
}

# Function to upgrade DERP server
upgrade() {
    check_root
    
    LATEST_TAG=$(get_latest_tag)
    echo "Latest version: $LATEST_TAG"
    
    # Get current port from running service
    CURRENT_ADDRESS=$(systemctl show -p ExecStart derper | grep -o -- '-a=:[0-9]*' | cut -d= -f2)
    
    echo "Stopping DERP server..."
    systemctl stop derper
    
    install_binary "$LATEST_TAG"
    
    echo "Starting DERP server..."
    systemctl start derper
    
    echo "Upgrade completed successfully!"
    echo "Server running on port $(extract_port "$CURRENT_ADDRESS")"
    echo "You can check the status with: systemctl status derper"
}

# Main script
case "${1}" in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    upgrade)
        upgrade
        ;;
    *)
        echo "Usage: $0 {install|uninstall|upgrade}"
        exit 1
        ;;
esac