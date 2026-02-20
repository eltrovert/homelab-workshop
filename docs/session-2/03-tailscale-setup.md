# Session 2.3: Secure Access with Tailscale

## Overview

Your Docker host is running, but you can only access it from your local network. What if you want to access your homelab from your laptop at a coffee shop? Or share a service with a friend without exposing your network to the public internet?

**Tailscale** solves this problem. It's a modern mesh VPN based on WireGuard that lets you securely access all your devices as if they were on the same local network.

In this section, you'll:
- Understand what Tailscale is and how it differs from traditional VPNs
- Install Tailscale on your Docker host
- Connect your personal devices
- Expose your entire homelab network through Tailscale
- Configure DNS and security rules

## What is Tailscale?

Tailscale is a zero-configuration VPN built on top of WireGuard. It creates a "mesh network" where all your devices can communicate securely and directly.

### Key Concepts

**Mesh Network:**
Instead of all traffic going through a central server, every device connects directly to every other device. This is faster and more resilient than traditional client-server VPNs.

**WireGuard:**
WireGuard is a modern cryptography-based VPN protocol that's faster, simpler, and more secure than OpenVPN or IPSec.

**Zero-Configuration:**
No manually managing certificates, IP addresses, or port forwarding. Tailscale handles it automatically.

**Tailnet:**
Your personal network of connected devices. All devices in your tailnet can see and reach each other.

## Tailscale vs Other VPN Options

### Traditional VPN (OpenVPN, IPSec)

| Feature | Tailscale | OpenVPN | IPSec |
|---------|-----------|---------|-------|
| Setup | Minutes | Hours | Hours |
| Performance | Excellent | Good | Good |
| Peer-to-peer | Yes | No (hub) | No (hub) |
| Zero-config | Yes | No | No |
| Certificate management | Automatic | Manual | Manual |
| Modern protocol | WireGuard | TLS | IPSec |
| Learning curve | Gentle | Moderate | Steep |

### WireGuard Standalone

Tailscale is actually a WireGuard-based VPN with better management. You could use raw WireGuard, but you'd need to:
- Manually manage keys and configurations
- Handle peer discovery
- Configure firewall rules
- Manage certificates

Tailscale does all this automatically.

## Use Cases for Tailscale

1. **Remote Access to Homelab**
   - Access your services from anywhere
   - No port forwarding or firewall rules needed
   - Secure tunnel to your network

2. **Sharing Services**
   - Give friends/family access to specific services
   - No need to expose to the internet
   - Can be revoked instantly

3. **Hybrid Work**
   - Consistent network access across locations
   - Works on mobile, laptop, desktop
   - Seamless roaming between networks

4. **Home Automation**
   - Home Assistant accessible from anywhere
   - Secure IoT device management
   - No public endpoints needed

5. **Multiple Homelabs**
   - If you have homelabs at multiple locations
   - Mesh them together securely
   - Share resources across locations

## Getting Started with Tailscale

### Step 1: Create a Tailscale Account

Visit https://tailscale.com and sign up. You can use:
- Google account
- Microsoft account
- GitHub account
- Email address

No credit card required. The free plan includes:
- Unlimited devices
- Unlimited users
- Unlimited data
- 100+ device limit on free tier

### Step 2: Install Tailscale on Docker Host

SSH into your Docker host container:

```bash
ssh root@192.168.10.50
```

Download and install Tailscale:

```bash
# Download and run Tailscale installation script
curl -fsSL https://tailscale.com/install.sh | sh
```

This script:
- Detects your OS (Ubuntu, Debian, CentOS, etc.)
- Downloads the appropriate Tailscale package
- Installs it
- Enables the service

### Step 3: Authenticate with Tailscale

After installation, bring up Tailscale:

```bash
tailscale up
```

This will output something like:

```
To authenticate, visit:

    https://login.tailscale.com/a/xxxxxxxxxxxxxxxx

Press Enter to continue
```

### Step 4: Authenticate in Web Browser

1. Open the URL from the previous command in your browser
2. Log in with your Tailscale account
3. Approve the device
4. Return to the terminal and press Enter

Tailscale will now connect and you should see:

```
Success! Your machine is now provisioned.
```

### Step 5: Find Your Tailscale IP

```bash
tailscale ip -4
```

Output example:
```
100.64.50.10
```

This is your device's IP address within the Tailscale network (called the "tailnet").

### Verify Status

```bash
tailscale status
```

Output:
```
  192.168.10.50  docker-host        linux   -
  100.64.50.10
```

## Installing Tailscale on Your Personal Devices

### On Your Laptop (Linux)

```bash
# Ubuntu/Debian
curl -fsSL https://tailscale.com/install.sh | sh

# Connect to your tailnet
tailscale up
```

### On Your Laptop (macOS)

```bash
# Using Homebrew
brew install tailscale

# Start the service
brew services start tailscale

# Connect
tailscale up
```

### On Your Laptop (Windows)

1. Download from https://tailscale.com/download/windows
2. Run the installer
3. Open Tailscale from system tray
4. Click "Connect" to sign in

### On Your Phone (iOS)

1. Install from App Store
2. Open the app
3. Tap "Connect"
4. Sign in with your Tailscale account

### On Your Phone (Android)

1. Install from Google Play Store
2. Open the app
3. Tap "Connect"
4. Sign in with your Tailscale account

## Testing Connectivity

### From Your Laptop

Open a terminal and test the connection:

```bash
# Ping your docker-host using its Tailscale IP
ping 100.64.50.10

# Try SSH
ssh root@100.64.50.10

# Or use the magic DNS name (easier to remember)
ping docker-host.your-tailnet
```

### Using Tailscale CLI

```bash
# See all your connected devices
tailscale status

# Ping another device in your tailnet
tailscale ping docker-host

# Show your Tailscale IP
tailscale ip -4

# Show your full IPv6 address
tailscale ip -6
```

## Exposing Your Homelab Network via Subnet Routing

So far you can only reach the Docker host directly. But what if you want to access your Proxmox cluster or other devices on your management network?

**Subnet routing** advertises your entire home network through Tailscale, making all devices accessible.

### Enable Subnet Routing on Docker Host

```bash
# Advertise the management VLAN
tailscale up --advertise-routes=192.168.10.0/24 --accept-routes
```

The output will show:

```
WARNING: This client is advertising the following routes:
  - 192.168.10.0/24

Enable them in the admin panel:
  https://login.tailscale.com/admin/machines
```

### Approve Routes in Admin Console

1. Visit https://login.tailscale.com/admin/machines
2. Find your **docker-host** machine
3. Click on it to expand
4. Look for "Subnets" section
5. Click "Edit route settings"
6. Check the box next to "192.168.10.0/24"
7. Save

Your laptop can now access any device on your 192.168.10.0/24 network via Tailscale!

### Test Subnet Routing

From your laptop:

```bash
# Ping your Proxmox node
ping 192.168.10.129

# SSH to the Proxmox node
ssh root@192.168.10.129

# Access Proxmox web UI
# Open browser to https://192.168.10.129:8006
```

## MagicDNS for Easy Access

Instead of remembering IP addresses, Tailscale has "MagicDNS" that lets you use simple names.

### Enable MagicDNS

1. Visit https://login.tailscale.com/admin/dns
2. Click "Enable MagicDNS"
3. Optional: Set custom DNS servers

### Use MagicDNS

```bash
# Instead of IP addresses, use friendly names
ping docker-host

# Or use full Tailscale domain
ping docker-host.your-username.ts.net

# Works from any device in your tailnet
ssh user@docker-host
```

## DNS Considerations

### Default DNS Resolution

By default, Tailscale uses a combination of:
- Your devices' configured DNS (usually your ISP's)
- MagicDNS for your tailnet devices

### Custom DNS Servers

If you're running your own DNS server (like AdGuard Home, which you'll deploy later):

```bash
# Configure Tailscale to use your DNS server
tailscale up --accept-dns=true

# Then configure your resolver
# See DNS settings at: https://login.tailscale.com/admin/dns
```

## Tailscale Access Control Lists (ACLs)

ACLs control which devices can communicate with which other devices. By default, all devices can reach all other devices.

### Basic ACL Example

Visit https://login.tailscale.com/admin/acls

Default policy:

```json
{
  // Allow all connections between devices
  "acls": [
    {
      "action": "accept",
      "src": ["*"],
      "dst": ["*:*"],
    }
  ]
}
```

### Restrict Access Example

Only allow your laptop to reach your Docker host:

```json
{
  "groups": {
    "group:family": ["user@example.com"],
    "group:servers": ["docker-host", "app-server"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["group:family"],
      "dst": ["group:servers:*"]
    }
  ]
}
```

For more complex ACL examples, see the Tailscale documentation.

## Sharing with Others (Optional)

### Invite Family/Friends

1. Visit https://login.tailscale.com/admin/users
2. Add new users (email addresses)
3. They'll get an invite link
4. They install Tailscale and authenticate
5. Approve their device in your admin console

Once approved, they can access resources you've shared (via ACLs).

### Revoke Access

Simply remove them from your tailnet:
1. Visit https://login.tailscale.com/admin/machines
2. Find their device
3. Click the "..." menu and select "Delete"

## Using Tailscale as an Exit Node (Advanced)

An exit node is a machine that routes all your traffic when enabled. This is useful for:
- Proxying traffic through your home network
- Accessing your ISP's services from elsewhere
- Testing your homelab's internet connectivity

### Configure Docker Host as Exit Node

```bash
# Advertise as exit node
tailscale up --advertise-routes=0.0.0.0/0 --accept-routes
```

Then approve in admin console.

On your laptop, enable the exit node:

```bash
# macOS/Linux
sudo tailscale set --exit-node=docker-host

# Verify
tailscale status | grep exit

# Disable when done
sudo tailscale set --exit-node=
```

**Warning:** Using your home internet as an exit node means all traffic goes through your home connection. Only enable temporarily for testing.

## Security Considerations

### Best Practices

1. **Keep Tailscale Updated**
   ```bash
   # Check version
   tailscale version

   # On Linux, use package manager
   apt update && apt upgrade
   ```

2. **Use Strong Authentication**
   - Use a password manager
   - Enable 2FA on your Tailscale account
   - Use a strong Tailscale password

3. **Regularly Review Devices**
   - Visit https://login.tailscale.com/admin/machines
   - Remove old/unused devices
   - Review ACLs quarterly

4. **Use ACLs Appropriately**
   - Don't allow open access to everything
   - Be specific about which devices need access
   - Regularly audit ACL rules

5. **Monitor Connected Devices**
   ```bash
   # See who's connected
   tailscale status

   # Check last activity
   # Visit admin console: https://login.tailscale.com/admin/machines
   ```

### Tailscale Security Features

- **Automatic Updates:** Security patches deployed automatically
- **Zero Trust:** Devices must be explicitly approved
- **Encryption:** All traffic encrypted with WireGuard
- **No Port Forwarding:** No need to expose ports to internet
- **No Public IPs:** All traffic stays within your tailnet

## Troubleshooting

### Can't Authenticate

```bash
# Clear authentication and try again
sudo tailscale logout

# Then reconnect
tailscale up
```

### Subnet Routing Not Working

```bash
# Verify routes are advertised
tailscale status

# Check if approved in admin console
# https://login.tailscale.com/admin/machines
```

### Slow Performance

- Check your internet connection speed
- Reduce distance to Tailscale relay servers
- Try disabling and re-enabling:
  ```bash
  tailscale down
  tailscale up
  ```

### DNS Not Resolving

```bash
# Verify MagicDNS is enabled
# https://login.tailscale.com/admin/dns

# Manually set DNS if needed
tailscale up --accept-dns=true
```

## Next Steps

You now have secure access to your homelab from anywhere. The next step is deploying services with Docker Compose on your Docker host, then exposing them securely through Tailscale and other mechanisms.

## Additional Resources

- **Tailscale Official Docs:** https://tailscale.com/kb/
- **Subnets Guide:** https://tailscale.com/kb/1019/subnets/
- **MagicDNS Guide:** https://tailscale.com/kb/1081/magicdns/
- **ACLs Guide:** https://tailscale.com/kb/1018/acls/
- **Community:** https://reddit.com/r/tailscale/

## Key Takeaways

- Tailscale provides zero-configuration mesh VPN using WireGuard
- It's perfect for secure homelab access from anywhere
- Subnet routing exposes your entire local network
- MagicDNS simplifies device names
- ACLs provide fine-grained access control
- It's free for personal use with unlimited devices
- Security through encryption and zero-trust device approval
