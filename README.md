# derp-cmd

[![License](https://img.shields.io/github/license/missuo/derp-cmd)](https://github.com/missuo/derp-cmd/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/missuo/derp-cmd)](https://github.com/missuo/derp-cmd/releases)

Easy to deploy and manage your own DERP (Designated Encrypted Relay for Packets) server, which can be used with Tailscale/Headscale.

## Requirements

- Operating System: Debian/Ubuntu
- Root access required
- A domain name with DNS A record configured

## Quick Start

### One-Click Installation

```bash
# Install DERP server
bash <(curl -Ls https://ssa.sx/derp) install

# Upgrade to the latest version
bash <(curl -Ls https://ssa.sx/derp) upgrade

# Uninstall DERP server
bash <(curl -Ls https://ssa.sx/derp) uninstall
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

## TODO

- [ ] Support Docker / Docker Compose
- [ ] Add Health Check

## Integration with Tailscale/Headscale

After setting up your DERP server, you can integrate it with:

- Tailscale: [Official Documentation](https://tailscale.com/kb/1118/custom-derp-servers/)
- Headscale: [Configuration Guide](https://headscale.net/running-headscale-linux/)

## Acknowledgments

- [Tailscale DERP Protocol](https://tailscale.com/blog/how-tailscale-works/)
- [Original DERP Server Implementation](https://github.com/tailscale/tailscale)

## Support

If you encounter any issues or have questions, please:
1. Check the [Issues](https://github.com/missuo/derp-cmd/issues) page
2. Create a new issue if your problem isn't already listed
3. Contact the author via Telegram for urgent matters

---
Copyright © 2024 by Vincent. All Rights Reserved.