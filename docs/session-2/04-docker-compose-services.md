# Session 2.4: Docker Compose Services

## Overview

You now have a Docker host running on Proxmox and secure remote access via Tailscale. Time to deploy actual services!

In this section, you'll:
- Install Docker and Docker Compose on your LXC container
- Understand Docker Compose basics (services, volumes, networks)
- Deploy a complete service stack including DNS, reverse proxy, management tools, and more
- Configure each service for your homelab
- Monitor and maintain your services

## Installing Docker

### Prerequisites

Your Docker host LXC container is configured with:
- Privilege: true (required)
- Nesting: true (required)
- FUSE: true (required)

These are necessary for Docker to run inside the container.

### Install Docker Engine

SSH into your Docker host:

```bash
ssh root@192.168.10.50
```

Download and run the official Docker installation script:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

This installs:
- Docker engine
- Docker CLI
- Docker daemon
- Required dependencies

Verify installation:

```bash
docker --version
# Docker version 24.0.x, build xxxxx

docker ps
# CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

### Install Docker Compose Plugin

```bash
apt install -y docker-compose-plugin
```

Verify:

```bash
docker compose version
# Docker Compose version v2.xx.x
```

### Manage Docker as Non-Root User (Optional)

By default, you need `sudo` to run Docker. To use Docker without `sudo`:

```bash
# Add your user to docker group
usermod -aG docker root

# Apply the group (no need to restart)
newgrp docker

# Test
docker ps
```

### Enable Docker at Boot

```bash
systemctl enable docker
systemctl start docker
```

## Docker Compose Basics

Docker Compose lets you define multiple services, networks, and volumes in a single YAML file, then deploy them all with one command.

### Key Concepts

**Service:** A containerized application (database, web server, DNS, etc.)

**Volume:** Persistent storage that survives container restarts

**Network:** Communication between containers (internal by default)

**Environment Variables:** Configuration passed to containers

**Restart Policy:** What to do if a container exits (no, always, unless-stopped, on-failure)

### Basic Structure

```yaml
services:
  # First service
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx/conf:/etc/nginx/conf.d
    restart: unless-stopped

  # Second service
  database:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - database_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  database_data:
```

## Complete Homelab Service Stack

Now let's create a comprehensive `docker-compose.yml` with all services for your homelab.

### Directory Structure

Create a directory for your services:

```bash
mkdir -p ~/services
cd ~/services

# Create subdirectories for configuration and data
mkdir -p {adguard,proxy,portainer,vaultwarden,homarr}
```

### Full docker-compose.yml

Create the file `~/services/docker-compose.yml`:

```yaml
version: '3.8'

services:
  # ============================================
  # AdGuard Home - DNS Ad Blocking
  # ============================================
  adguard:
    image: adguard/adguardhome:latest
    container_name: adguardhome
    restart: unless-stopped
    ports:
      # DNS ports
      - "53:53/tcp"
      - "53:53/udp"
      # Setup wizard
      - "3000:3000/tcp"
      # Web UI (HTTP redirect)
      - "8080:80/tcp"
      # HTTPS
      - "4443:443/tcp"
      # DNS over TLS
      - "853:853/tcp"
      # DNS over HTTPS
      - "8443:443/tcp"
    volumes:
      # Working directory (configs, certificates)
      - ./adguard/work:/opt/adguardhome/work
      # Configuration directory
      - ./adguard/conf:/opt/adguardhome/conf
    environment:
      - TZ=UTC
    networks:
      - homelab
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080/"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  # ============================================
  # Nginx Proxy Manager - Reverse Proxy & SSL
  # ============================================
  nginx-proxy-manager:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      # HTTP traffic
      - "80:80"
      # HTTPS traffic
      - "443:443"
      # Admin interface
      - "81:81"
    volumes:
      # Manager data
      - ./proxy/data:/data
      # Let's Encrypt certificates
      - ./proxy/letsencrypt:/etc/letsencrypt
    environment:
      - TZ=UTC
      - DISABLE_IPV6=true
    networks:
      - homelab
    depends_on:
      - adguard
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:81/"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 20s

  # ============================================
  # Portainer - Docker Management UI
  # ============================================
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      # HTTP interface
      - "9000:9000"
      # HTTPS interface
      - "9443:9443"
    volumes:
      # Docker socket for management
      - /var/run/docker.sock:/var/run/docker.sock
      # Portainer data
      - ./portainer/data:/data
    environment:
      - TZ=UTC
    networks:
      - homelab
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:9000/"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 30s

  # ============================================
  # Vaultwarden - Password Manager
  # ============================================
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    ports:
      - "8090:80"
    volumes:
      # Vault data
      - ./vaultwarden/data:/data
    environment:
      - DOMAIN=https://vault.example.com
      - SIGNUPS_ALLOWED=false  # Disable public signups
      - WEBSOCKET_ENABLED=true  # Enable websocket for real-time sync
      - WEBSOCKET_PORT=3012
      - TZ=UTC
      - ADMIN_TOKEN=your-secure-admin-token-here
      - LOG_LEVEL=info
      - LOG_FILE=/data/vaultwarden.log
    networks:
      - homelab
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s

  # ============================================
  # Cloudflare Tunnel - Public Access
  # ============================================
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=your-cloudflare-tunnel-token-here
      - TZ=UTC
    networks:
      - homelab
    depends_on:
      - nginx-proxy-manager
    healthcheck:
      test: ["CMD", "cloudflared", "tunnel", "info"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  # ============================================
  # Homarr - Dashboard
  # ============================================
  homarr:
    image: ghcr.io/ajnart/homarr:latest
    container_name: homarr
    restart: unless-stopped
    ports:
      - "7575:7575"
    volumes:
      # Configuration
      - ./homarr/configs:/app/data/configs
      # Custom icons
      - ./homarr/icons:/app/public/icons
      # Docker socket for info
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - TZ=UTC
      - DOCKER_HOST=unix:///var/run/docker.sock
    networks:
      - homelab
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:7575/"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

networks:
  # Internal network for service-to-service communication
  homelab:
    driver: bridge
    driver_opts:
      com.docker.network.driver.mtu: 1500

volumes:
  # If you want to define volumes here (optional)
  # adguard_work:
  # adguard_conf:
  # proxy_data:
  # portainer_data:
```

## Deploying the Stack

### Initialize the Stack

Navigate to your services directory:

```bash
cd ~/services
```

Create data directories:

```bash
mkdir -p {adguard,proxy,portainer,vaultwarden,homarr}/{work,conf,data,configs,icons} 2>/dev/null
```

### Start All Services

```bash
docker compose up -d
```

This will:
1. Download images (first time only)
2. Create the internal network
3. Start all containers in the background

Monitor the startup:

```bash
docker compose logs -f
```

Once all services are healthy, press Ctrl+C to exit logs.

### Verify Services Are Running

```bash
docker compose ps

# Output should show all services as "Up"
# CONTAINER ID   IMAGE                                    COMMAND                  CREATED         STATUS                    PORTS
# xxx            adguard/adguardhome:latest              "/opt/adguardhome/..."  5 seconds ago   Up 2 seconds (healthy)    0.0.0.0:53->53/tcp, :::53->53/tcp, 0.0.0.0:3000->3000/tcp...
```

## Service Configuration

### AdGuard Home Setup

Access the setup wizard:
```
http://192.168.10.50:3000
```

Or if you have Tailscale:
```
http://docker-host:3000
```

**Initial Setup:**
1. Admin page: Keep port 80 and listening on all interfaces
2. User account: Set admin password
3. DNS server: Keep ports 53 (TCP/UDP)

**Configuration After Setup:**

Access the dashboard:
```
http://192.168.10.50:8080
```

Configure upstream DNS servers (Settings > DNS settings):
- Primary: 1.1.1.1 (Cloudflare)
- Secondary: 8.8.8.8 (Google)

Enable features (Settings > General):
- Filtering
- Safebrowsing
- Parental control (optional)

### Nginx Proxy Manager Setup

Access the admin interface:
```
http://192.168.10.50:81
```

**Default credentials:**
- Email: `admin@example.com`
- Password: `changeme`

**Change credentials:**
1. Login
2. Click your email (top right)
3. Change password
4. Save

**Add a Proxy Host:**
1. Click "Proxy Hosts" > "Add Proxy Host"
2. Domain names: `service.example.com`
3. Scheme: `http` (internal services)
4. Forward hostname/IP: `service-container` (or IP)
5. Forward port: Service port
6. SSL Certificate: Request a new SSL cert from Let's Encrypt
7. Save

### Portainer Setup

Access the web interface:
```
https://192.168.10.50:9443
```

Or via Tailscale:
```
https://docker-host:9443
```

**Initial Setup:**
1. Create admin user and password
2. Name your environment (e.g., "Docker Host")
3. Click "Connect"

**Key Features:**
- View running containers
- View logs and stats
- Manage images and volumes
- Execute commands in containers

### Vaultwarden Setup

Access the application:
```
http://192.168.10.50:8090
```

**First Login:**
1. Click "Create account"
2. Set email address
3. Set master password
4. Confirm
5. You'll get an account invitation to verify email

**Admin Panel:**
Access at `/admin` if you set `ADMIN_TOKEN`:
```
http://192.168.10.50:8090/admin
```

**Important Settings:**
- Update `DOMAIN` to your actual domain (e.g., `https://vault.yourdomain.com`)
- Keep `SIGNUPS_ALLOWED=false` for security
- Use a strong `ADMIN_TOKEN`

### Cloudflare Tunnel Setup

**Prerequisites:**
- Cloudflare account with a domain
- Cloudflared installed locally for tunnel creation

**Create Tunnel:**

```bash
# On your laptop, install cloudflared
brew install cloudflare/cloudflare/cloudflared  # macOS
# or download from https://github.com/cloudflare/cloudflared/releases

# Create a tunnel
cloudflared tunnel create myhomelab

# Copy the token and add to docker-compose.yml
```

**Configure Routes:**

In Cloudflare dashboard:
1. Go to Zero Trust > Networks > Tunnels
2. Select your tunnel
3. Add public hostnames pointing to internal services:
   - `homelab.yourdomain.com` → `localhost:7575` (Homarr)
   - `adguard.yourdomain.com` → `localhost:8080` (AdGuard)
   - `vault.yourdomain.com` → `localhost:8090` (Vaultwarden)

### Homarr Dashboard Setup

Access the dashboard:
```
http://192.168.10.50:7575
```

**Initial Setup:**
1. Create your account
2. Create a dashboard
3. Add shortcuts to your services

**Add Service Shortcuts:**
1. Click "Edit"
2. Click "Add item"
3. Select "Shortcut"
4. Fill in:
   - Title: Service name
   - URL: Service URL
   - Icon: Select or upload
5. Save

## Managing Services

### View Logs

```bash
# All services
docker compose logs

# Specific service
docker compose logs nginx-proxy-manager

# Follow logs (live)
docker compose logs -f adguard

# Last 50 lines
docker compose logs --tail=50
```

### Stop Services

```bash
# Stop all (but don't remove)
docker compose stop

# Stop specific service
docker compose stop adguard

# Stop and remove containers (keep data)
docker compose down
```

### Restart Services

```bash
# Restart all
docker compose restart

# Restart specific service
docker compose restart nginx-proxy-manager
```

### Update Services

```bash
# Pull latest images
docker compose pull

# Recreate containers with new images
docker compose up -d

# All at once
docker compose pull && docker compose up -d
```

### Check Service Health

```bash
# View container stats
docker stats

# View details of a specific container
docker inspect adguardhome

# Check service logs for errors
docker compose logs nginx-proxy-manager | grep -i error
```

## Accessing Services

### Service Access Reference

| Service | Port | URL | Purpose |
|---------|------|-----|---------|
| AdGuard Home | 8080 | http://192.168.10.50:8080 | DNS filtering dashboard |
| Nginx Proxy Manager | 81 | http://192.168.10.50:81 | Reverse proxy management |
| Portainer | 9443 | https://192.168.10.50:9443 | Docker container management |
| Vaultwarden | 8090 | http://192.168.10.50:8090 | Password manager |
| Homarr | 7575 | http://192.168.10.50:7575 | Dashboard |
| DNS (AdGuard) | 53 | 192.168.10.50:53 | DNS server |

### Via Tailscale

If you set up Tailscale subnet routing (192.168.10.0/24):

```bash
# Use friendly names
http://docker-host:8080  # AdGuard
http://docker-host:81    # Nginx Proxy Manager
https://docker-host:9443 # Portainer
```

## Maintenance

### Regular Tasks

**Daily:**
- Monitor error logs
- Check service health in Portainer

**Weekly:**
- Backup Vaultwarden data
- Check for service updates

**Monthly:**
- Update container images
- Review Docker resource usage
- Clean up old images and volumes

### Cleanup

```bash
# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Full cleanup (safer with compose)
docker compose down -v  # Remove containers and volumes
```

### Backup Data

```bash
# Backup AdGuard configuration
tar -czf adguard_backup.tar.gz ./adguard/

# Backup Vaultwarden data
tar -czf vaultwarden_backup.tar.gz ./vaultwarden/

# Store backups securely
cp *_backup.tar.gz /backup/location/
```

## Troubleshooting

### Service Won't Start

```bash
# Check logs
docker compose logs servicename

# Verify image is available
docker images | grep imagename

# Try pulling latest
docker compose pull servicename
docker compose up -d servicename
```

### Port Already in Use

```bash
# Find which process is using the port
sudo lsof -i :8080

# Either change the port in docker-compose.yml or stop the other service
```

### Containers Keep Restarting

```bash
# Check logs for errors
docker compose logs -f servicename

# View detailed error
docker logs --tail 100 servicename
```

### DNS Not Working

```bash
# Restart AdGuard
docker compose restart adguard

# Set as system DNS (in container)
echo "nameserver 192.168.10.50" | sudo tee /etc/resolv.conf

# Test DNS
nslookup google.com 192.168.10.50
```

## Next Steps

You now have a comprehensive service stack running:
- DNS filtering with AdGuard
- Reverse proxy with Nginx Proxy Manager
- Container management with Portainer
- Password management with Vaultwarden
- Dashboard with Homarr
- Public internet access with Cloudflare Tunnel

In the next section, you'll explore additional services you can deploy to extend your homelab.

## Useful Docker Compose Commands

```bash
# Start services in background
docker compose up -d

# Start and rebuild images
docker compose up -d --build

# View running services
docker compose ps

# View all services (including stopped)
docker compose ps -a

# View logs with timestamps
docker compose logs --timestamps

# Execute command in container
docker compose exec servicename bash

# View resource usage
docker compose stats

# Validate compose file syntax
docker compose config

# Stop all services
docker compose stop

# Restart specific service
docker compose restart servicename

# Remove everything (destructive!)
docker compose down

# Remove with volumes
docker compose down -v

# Remove with images
docker compose down --rmi all
```
