# derp-cmd

[![License](https://img.shields.io/github/license/missuo/derp-cmd)](https://github.com/missuo/derp-cmd/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/missuo/derp-cmd)](https://github.com/missuo/derp-cmd/releases)

Easy to deploy and manage your own DERP (Designated Encrypted Relay for Packets) server, which can be used with Tailscale/Headscale.

## Requirements

- Operating System: Debian/Ubuntu
- Root access required
- A domain name with DNS A record configured
- Port 443 must be available
- Basic commands: `curl`, `jq`, `systemctl`, `netstat` (will be automatically installed if missing)

## Quick Start

### One-Click Installation

```bash
bash <(curl -Ls https://ssa.sx/derp) install

bash <(curl -Ls https://ssa.sx/derp) upgrade

bash <(curl -Ls https://ssa.sx/derp) uninstall
```

### Manual Installation

You can also download and run the script manually:

```bash
# Download the script
curl -O https://raw.githubusercontent.com/missuo/derp-cmd/main/install.sh

# Make it executable
chmod +x install.sh

# Run installation
./install.sh install
```

## Available Commands

```bash
# Install DERP server
./install.sh install

# Upgrade to the latest version
./install.sh upgrade

# Uninstall DERP server
./install.sh uninstall
```

## Features

- 🚀 One-click installation
- 🔄 Easy upgrade to the latest version
- 🧹 Clean uninstallation
- 🔒 Automatic TLS certificate management
- 💫 Systemd service integration
- 🔍 Port availability check
- ⚡ Binary verification

## Service Management

```bash
# Check service status
systemctl status derper

# Start service
systemctl start derper

# Stop service
systemctl stop derper

# View logs
journalctl -u derper -f
```

## Troubleshooting

1. **Port 443 in use:**
   ```bash
   # Check what's using port 443
   netstat -tulpn | grep :443
   
   # Stop the service using port 443 (example: nginx)
   systemctl stop nginx
   ```

2. **Domain DNS setup:**
   - Ensure your domain's A record points to your server's IP address
   - Allow several minutes for DNS propagation after making changes

3. **Common error messages:**
   - "Error: Please run as root" - Use sudo or switch to root user
   - "Port 443 is already in use" - Free up port 443 first
   - "Could not fetch latest release tag" - Check your internet connection

## Integration with Tailscale/Headscale

After setting up your DERP server, you can integrate it with:

- Tailscale: [Official Documentation](https://tailscale.com/kb/1118/custom-derp-servers/)
- Headscale: [Configuration Guide](https://headscale.net/running-headscale-linux/)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Tailscale DERP Protocol](https://tailscale.com/blog/how-tailscale-works/)
- [Original DERP Server Implementation](https://github.com/tailscale/tailscale)

## Author

Vincent Yang
- Telegram: [@missuo](https://t.me/missuo)
- GitHub: [@missuo](https://github.com/missuo)

## Support

If you encounter any issues or have questions, please:
1. Check the [Issues](https://github.com/missuo/derp-cmd/issues) page
2. Create a new issue if your problem isn't already listed
3. Contact the author via Telegram for urgent matters

---
Copyright © 2024 by Vincent. All Rights Reserved.