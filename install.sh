#!/bin/bash

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

# Function to validate hostname DNS resolution
validate_hostname() {
    local hostname="$1"
    local server_ip=$(curl -s https://ipinfo.io/ip)
    local dns_ip=$(dig +short "$hostname" | head -n1)

    if [ -z "$dns_ip" ]; then
        echo "Error: Could not resolve hostname $hostname"
        return 1
    fi

    if [ "$server_ip" != "$dns_ip" ]; then
        echo "Error: Hostname $hostname does not resolve to this server's IP ($server_ip)"
        echo "Please ensure your DNS is properly configured before continuing."
        return 1
    fi

    return 0
}

# Check required commands
for cmd in curl jq systemctl netstat dig; do
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

# Prompt for hostname
while true; do
    read -p "Please enter your hostname (e.g., derp.example.com): " HOSTNAME
    if validate_hostname "$HOSTNAME"; then
        break
    fi
done

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
Description=Derper DERP Server
After=network.target

[Service]
ExecStart=/usr/local/bin/derper -hostname $HOSTNAME
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