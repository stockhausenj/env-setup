# Tailscale Role

Ansible role for installing and configuring Tailscale VPN on Ubuntu and macOS.

## Description

This role handles the complete installation and setup of Tailscale including:
- Tailscale client installation
- Repository configuration (Ubuntu)
- Service management
- Optional automatic network connection with auth key

## What is Tailscale?

Tailscale is a zero-config VPN built on WireGuard that creates a secure network between your devices. It's perfect for:
- Accessing your home lab remotely
- Connecting to development servers
- Secure communication between team members
- Remote access to services

## Requirements

- Ansible 2.9 or higher
- Ubuntu (Focal, Jammy, Noble) or macOS
- For Ubuntu: sudo privileges for package installation
- For macOS: Homebrew must be installed
- Optional: Tailscale auth key for automatic connection

## Role Variables

Default values are defined in `defaults/main.yml`:

```yaml
# Enable and start the Tailscale service on Ubuntu
tailscale_enable_service: true

# Optional: Tailscale auth key for automatic connection
# Leave empty to manually authenticate after installation
tailscale_authkey: ""

# Optional: Additional tailscale up arguments
# Default: --accept-routes (accept subnet routes from other devices)
tailscale_up_args: "--accept-routes"
```

### Getting an Auth Key

To automatically connect devices to your Tailscale network:

1. Go to https://login.tailscale.com/admin/settings/keys
2. Generate a new auth key
3. Set it as `tailscale_authkey` in your playbook

**Security Note:** Auth keys are sensitive! Store them securely using Ansible Vault or environment variables.

## Dependencies

None.

## Example Playbook

### Basic Installation (Manual Authentication)

```yaml
- hosts: localhost
  roles:
    - tailscale
```

After running the playbook, manually authenticate:
```bash
sudo tailscale up
```

### Installation with Auto-Connect

```yaml
- hosts: localhost
  roles:
    - role: tailscale
      vars:
        tailscale_authkey: "tskey-auth-xxxxxxxxxxxxx"
```

### Installation with Additional Options

```yaml
- hosts: localhost
  roles:
    - role: tailscale
      vars:
        tailscale_authkey: "tskey-auth-xxxxxxxxxxxxx"
        tailscale_up_args: "--accept-routes --ssh"
```

### Using Ansible Vault for Auth Key

Create a vault file:
```bash
ansible-vault create vars/tailscale_secrets.yml
```

Add your key:
```yaml
tailscale_authkey: "tskey-auth-xxxxxxxxxxxxx"
```

Use in playbook:
```yaml
- hosts: localhost
  vars_files:
    - vars/tailscale_secrets.yml
  roles:
    - tailscale
```

Run with:
```bash
ansible-playbook playbook.yml --ask-vault-pass
```

## Common Tailscale Up Arguments

You can customize the connection with these common arguments:

- `--accept-routes` - Accept subnet routes advertised by other nodes
- `--advertise-routes=<routes>` - Advertise routes to your network (e.g., `192.168.1.0/24`)
- `--ssh` - Enable Tailscale SSH
- `--accept-dns` - Accept DNS configuration from Tailscale
- `--hostname=<name>` - Set a custom hostname
- `--advertise-exit-node` - Offer to be an exit node
- `--exit-node=<node>` - Use another node as an exit node

Example:
```yaml
tailscale_up_args: "--accept-routes --ssh --hostname=my-dev-box"
```

## Post-Installation

### Check Status

```bash
tailscale status
```

### View IP Address

```bash
tailscale ip
```

### Disconnect

```bash
sudo tailscale down
```

### Reconnect

```bash
sudo tailscale up
```

## Platform Differences

### macOS
- Installed via Homebrew Cask (GUI app)
- Includes menu bar app and system extension
- Available in Applications folder
- Shows up in System Settings > General > Login Items & Extensions
- Can be managed via GUI or command line

### Ubuntu
- Installed via official Tailscale repository
- Service managed by systemd
- Automatically enabled and started (configurable)

## Troubleshooting

### Connection Issues

Check service status:
```bash
# Ubuntu
sudo systemctl status tailscaled

# macOS
tailscale status
```

### View Logs

```bash
# Ubuntu
sudo journalctl -u tailscaled -f

# macOS
log stream --predicate 'process == "tailscaled"'
```

### Reauthenticate

If your connection expires:
```bash
sudo tailscale up
```

## Security Considerations

- Store auth keys securely (use Ansible Vault)
- Use reusable but ephemeral keys when possible
- Regularly rotate auth keys
- Review connected devices in the admin console
- Enable MFA on your Tailscale account

## Useful Links

- [Tailscale Documentation](https://tailscale.com/kb/)
- [Tailscale Admin Console](https://login.tailscale.com/admin)
- [Generate Auth Keys](https://login.tailscale.com/admin/settings/keys)
- [Tailscale KB: Install](https://tailscale.com/kb/1031/install-linux/)

## License

MIT

## Author

Jay Stockhausen
