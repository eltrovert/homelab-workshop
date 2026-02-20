# Session 2.5: Additional Self-Hosted Services

## Overview

You've deployed a solid foundation with DNS, reverse proxy, container management, and a dashboard. Now it's time to explore additional services that can transform your homelab into a comprehensive personal technology platform.

In this section, you'll see how to deploy:
- Photo management (Immich)
- Cloud storage (Nextcloud)
- Media servers (Plex/Jellyfin)
- Monitoring and observability
- Source control and automation
- Smart home integration
- And many other services

Each service includes a Docker Compose snippet and basic setup instructions.

## Philosophy: Choose Your Services

Don't try to deploy everything at once. A homelab is personal. Start with services that solve your actual problems:

- Do you take lots of photos? → Immich
- Need cloud storage like Dropbox? → Nextcloud
- Have a media library? → Jellyfin
- Want to know if services are down? → Uptime Kuma
- Need to self-host Git? → Gitea
- Have smart devices? → Home Assistant

Pick 1-2 services, master them, then add more.

## Immich: Self-Hosted Google Photos

### What is Immich?

Immich is a self-hosted photo and video backup solution. Think Google Photos but you own everything.

**Key Features:**
- Automatic photo backup from phone (iOS/Android)
- Machine learning search and face recognition (optional)
- Organize by date, location, person
- Shared albums
- Web interface
- API for integrations

**Why Use It:**
- Privacy: Your photos never leave your network
- No subscription fees
- Unlimited storage (limited by disk)
- Full control over your media
- Beautiful interface

### Docker Compose Setup

Add to your docker-compose.yml or create a new file:

```yaml
# Immich Components
services:
  immich-server:
    image: ghcr.io/immich-app/immich-server:latest
    container_name: immich-server
    command: start-server
    restart: unless-stopped
    ports:
      - "3001:3001"
    volumes:
      - ./immich/upload:/usr/src/app/upload
      - ./immich/external:/usr/src/app/external
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DB_DRIVER=postgres
      - DB_HOSTNAME=immich-postgres
      - DB_USERNAME=postgres
      - DB_PASSWORD=postgres
      - DB_NAME=immich
      - REDIS_HOSTNAME=immich-redis
      - REDIS_PORT=6379
      - TZ=UTC
    depends_on:
      - immich-postgres
      - immich-redis
    networks:
      - homelab
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/api/server/version"]
      interval: 30s
      timeout: 5s
      retries: 3

  immich-microservices:
    image: ghcr.io/immich-app/immich-server:latest
    container_name: immich-microservices
    command: start-microservices
    restart: unless-stopped
    volumes:
      - ./immich/upload:/usr/src/app/upload
      - ./immich/external:/usr/src/app/external
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DB_DRIVER=postgres
      - DB_HOSTNAME=immich-postgres
      - DB_USERNAME=postgres
      - DB_PASSWORD=postgres
      - DB_NAME=immich
      - REDIS_HOSTNAME=immich-redis
      - REDIS_PORT=6379
      - TZ=UTC
      - IMMICH_MACHINE_LEARNING_ENABLED=true
      - IMMICH_MACHINE_LEARNING_URL=http://immich-ml:3003
    depends_on:
      - immich-postgres
      - immich-redis
      - immich-ml
    networks:
      - homelab

  immich-ml:
    image: ghcr.io/immich-app/immich-machine-learning:latest
    container_name: immich-ml
    restart: unless-stopped
    volumes:
      - ./immich/model-cache:/cache
    environment:
      - TZ=UTC
    networks:
      - homelab
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3003/ping"]
      interval: 30s
      timeout: 5s
      retries: 3

  immich-postgres:
    image: postgres:15-alpine
    container_name: immich-postgres
    restart: unless-stopped
    volumes:
      - ./immich/postgres:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=immich
      - TZ=UTC
    networks:
      - homelab
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 5s
      retries: 3

  immich-redis:
    image: redis:7-alpine
    container_name: immich-redis
    restart: unless-stopped
    volumes:
      - ./immich/redis:/data
    networks:
      - homelab
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 5s
      retries: 3
```

### Initial Setup

1. Access the web interface:
   ```
   http://192.168.10.50:3001
   ```

2. Create an admin account
3. Install the Immich mobile app (iOS/Android)
4. Configure backup settings in the app
5. Enable optional ML features in settings

### Machine Learning Features

Immich can use ML for:
- Face recognition
- Object detection
- CLIP search (semantic search)

This requires the `immich-ml` service. It uses more resources, so consider your hardware.

## Nextcloud: Self-Hosted Cloud Storage

### What is Nextcloud?

Nextcloud is a file hosting platform with synchronization, sharing, and collaboration features. Like Dropbox but open-source and self-hosted.

**Key Features:**
- File sync and share
- Calendar and contacts
- Tasks and notes
- Talk (video calls)
- Password manager integration
- Collaborative editing
- Mobile apps

**Why Use It:**
- Own your data completely
- Unlimited storage (by your hardware)
- Rich app ecosystem
- Great for family use
- Excellent web interface

### Docker Compose Setup

```yaml
services:
  nextcloud-app:
    image: nextcloud:latest
    container_name: nextcloud
    restart: unless-stopped
    ports:
      - "8081:80"
    volumes:
      - ./nextcloud/data:/var/www/html
      - ./nextcloud/config:/var/www/html/config
    environment:
      - NEXTCLOUD_ADMIN_USER=admin
      - NEXTCLOUD_ADMIN_PASSWORD=changeme
      - POSTGRES_HOST=nextcloud-postgres
      - POSTGRES_DB=nextcloud
      - POSTGRES_USER=nextcloud
      - POSTGRES_PASSWORD=changeme
      - NEXTCLOUD_TRUSTED_DOMAINS=192.168.10.50 localhost docker-host
    depends_on:
      - nextcloud-postgres
      - nextcloud-redis
    networks:
      - homelab
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 5s
      retries: 3

  nextcloud-postgres:
    image: postgres:15-alpine
    container_name: nextcloud-postgres
    restart: unless-stopped
    volumes:
      - ./nextcloud/postgres:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=nextcloud
      - POSTGRES_USER=nextcloud
      - POSTGRES_PASSWORD=changeme
    networks:
      - homelab
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U nextcloud"]
      interval: 30s
      timeout: 5s
      retries: 3

  nextcloud-redis:
    image: redis:7-alpine
    container_name: nextcloud-redis
    restart: unless-stopped
    networks:
      - homelab
```

### Initial Setup

1. Access the web interface:
   ```
   http://192.168.10.50:8081
   ```

2. Wait for installation to complete (may take 1-2 minutes)
3. Log in with admin credentials
4. Set SMTP for email notifications (Settings > Email)
5. Install useful apps:
   - Calendar (CalDAV support)
   - Contacts (CardDAV support)
   - Files (built-in)
   - Talk (video calls)
   - Notes

### Enable HTTPS

Use Nginx Proxy Manager to add HTTPS:
1. Add proxy host for `nextcloud.yourdomain.com`
2. Forward to `nextcloud-app:80`
3. Enable SSL certificate

## Jellyfin: Self-Hosted Media Server

### What is Jellyfin?

Jellyfin is a media system that lets you organize and stream your personal media collection.

**Key Features:**
- Organize movies and TV shows
- Stream anywhere (web, mobile, TV apps)
- Auto-download subtitles
- Transcode for bandwidth savings
- Beautiful interface
- Share with family

**Why Choose Jellyfin Over Plex:**
- Open-source and free
- No subscription required
- No account required
- Better privacy
- Active development

### Docker Compose Setup

```yaml
services:
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    ports:
      - "8096:8096"
      - "8920:8920"  # HTTPS
    volumes:
      - ./jellyfin/config:/config
      - ./jellyfin/cache:/cache
      # Add your media library
      - /mnt/media/movies:/media/movies:ro
      - /mnt/media/tv:/media/tv:ro
      - /mnt/media/music:/media/music:ro
    environment:
      - TZ=UTC
    networks:
      - homelab
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8096/health"]
      interval: 30s
      timeout: 5s
      retries: 3
    # Optional: Use host network for better streaming
    # network_mode: "host"
```

### Initial Setup

1. Access http://192.168.10.50:8096
2. Complete the setup wizard
3. Add media libraries (Movies, TV Shows, Music)
4. Configure transcoding (if needed)
5. Install mobile apps for streaming

### Add Media Libraries

The key is mounting your actual media:

```yaml
volumes:
  - /mnt/nas/movies:/media/movies:ro
  - /mnt/nas/tv:/media/tv:ro
```

Structure your media as:
```
/mnt/nas/movies/
├── Movie Title (2020)/
│   └── Movie.Title.2020.mkv
├── Another Movie (2021)/
│   └── Another.Movie.2021.mkv
```

## Monitoring and Observability

### Uptime Kuma: Service Monitoring

Monitor if your services are online.

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: unless-stopped
    ports:
      - "3002:3001"
    volumes:
      - ./uptime-kuma/data:/app/data
    networks:
      - homelab
```

Access: http://192.168.10.50:3002

**Setup:**
1. Create admin account
2. Add monitors for each service:
   - HTTP monitors for web services
   - DNS monitors for DNS service
   - TCP/UDP monitors for other services
3. Configure notifications (email, Discord, Slack)

### Grafana + Prometheus: Advanced Monitoring

For detailed metrics and dashboards:

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus/data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    networks:
      - homelab

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ./grafana/data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - homelab
```

This requires more setup but gives you beautiful dashboards.

## Development and Automation

### Gitea: Self-Hosted Git

Host your own Git repositories.

```yaml
services:
  gitea:
    image: gitea/gitea:latest
    container_name: gitea
    restart: unless-stopped
    ports:
      - "3010:3000"
      - "2222:22"
    volumes:
      - ./gitea/data:/data
    environment:
      - TZ=UTC
      - RUN_MODE=prod
    networks:
      - homelab
```

Access: http://192.168.10.50:3010

Perfect for:
- Personal projects
- Infrastructure as code (Terraform, etc.)
- Documentation
- Automation scripts

### Home Assistant: Smart Home Hub

Integrate and control smart home devices.

```yaml
services:
  home-assistant:
    image: ghcr.io/home-assistant/home-assistant:latest
    container_name: home-assistant
    restart: unless-stopped
    ports:
      - "8123:8123"
    volumes:
      - ./homeassistant/config:/config
      - /etc/localtime:/etc/localtime:ro
    environment:
      - TZ=UTC
    networks:
      - homelab
    # Recommended: use host network for better device discovery
    # network_mode: "host"
```

Access: http://192.168.10.50:8123

**Setup:**
1. Create account
2. Add integrations for your devices
3. Create automations
4. Build dashboards

## Storage and Backup

### Syncthing: Decentralized Sync

Sync files between devices without a central server.

```yaml
services:
  syncthing:
    image: syncthing/syncthing:latest
    container_name: syncthing
    restart: unless-stopped
    ports:
      - "8384:8384"  # Web UI
      - "22000:22000/tcp"  # Sync protocol
      - "22000:22000/udp"
      - "21027:21027/udp"  # Discovery
    volumes:
      - ./syncthing/config:/var/syncthing/config
      - ./syncthing/data:/var/syncthing/data
    environment:
      - PUID=0
      - PGID=0
      - TZ=UTC
    networks:
      - homelab
```

Access: http://192.168.10.50:8384

Perfect for syncing documents, photos, and config files.

## Complete Service Reference Table

| Service | Port | Purpose | Complexity | Resources |
|---------|------|---------|-----------|-----------|
| AdGuard Home | 8080 | DNS ad blocking | Easy | Low |
| Nginx Proxy Manager | 81 | Reverse proxy | Easy | Low |
| Portainer | 9443 | Container management | Easy | Low |
| Vaultwarden | 8090 | Password manager | Easy | Medium |
| Homarr | 7575 | Dashboard | Easy | Low |
| Immich | 3001 | Photo backup | Medium | High |
| Nextcloud | 8081 | Cloud storage | Medium | High |
| Jellyfin | 8096 | Media streaming | Medium | High |
| Uptime Kuma | 3002 | Service monitoring | Easy | Low |
| Gitea | 3010 | Git server | Easy | Medium |
| Home Assistant | 8123 | Smart home hub | Hard | Medium |
| Grafana + Prometheus | 3000, 9090 | Advanced monitoring | Hard | High |
| Syncthing | 8384 | File sync | Easy | Medium |

## Deployment Strategies

### Strategy 1: Start Minimal

Deploy only essential services:
- AdGuard Home
- Nginx Proxy Manager
- Portainer

Then add one service at a time as you learn.

### Strategy 2: Complete Stack

Deploy everything upfront. Manage complexity as you go.

Pros: All services available immediately
Cons: More initial troubleshooting, higher resource usage

### Strategy 3: Staged Rollout

Week 1: DNS and reverse proxy
Week 2: Container management and dashboard
Week 3: Photo and file storage
Week 4: Media server
Week 5: Monitoring and automation

This approach gives you time to master each layer.

## Managing Resources

### Monitor Docker Resource Usage

```bash
docker stats

# Limit memory per service (in docker-compose.yml)
services:
  service:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1'
```

### Prioritize by Need

**High Priority (Always Deploy):**
- AdGuard Home (improves all networks)
- Nginx Proxy Manager (needed for all HTTPS)

**Important (Soon):**
- Portainer (manage everything)
- Uptime Kuma (know when things break)

**Nice to Have (Later):**
- Photo storage
- Media server
- Cloud storage

## Best Practices for Multi-Service Deployments

### 1. Use Compose Overrides

Keep base compose file stable, use overrides for customizations:

```bash
# docker-compose.yml (base)
# docker-compose.override.yml (local customizations)

docker compose -f docker-compose.yml -f docker-compose.override.yml up -d
```

### 2. Separate by Function

Organize services in different compose files:

```bash
# docker-compose.core.yml (DNS, proxy, management)
# docker-compose.storage.yml (Nextcloud, Jellyfin)
# docker-compose.smart-home.yml (Home Assistant, etc.)

docker compose -f docker-compose.core.yml up -d
```

### 3. Environment Variables

Use .env files for all configuration:

```bash
# .env
ADMIN_PASSWORD=secure_password
DOMAIN=example.com
TZ=UTC

# docker-compose.yml
environment:
  - ADMIN_PASSWORD=${ADMIN_PASSWORD}
  - DOMAIN=${DOMAIN}
```

### 4. Backup Strategy

Backup important data regularly:

```bash
# Daily backup script
#!/bin/bash
BACKUP_DIR="/mnt/backup"
DATE=$(date +%Y%m%d)

# Backup Vaultwarden
tar -czf $BACKUP_DIR/vaultwarden-$DATE.tar.gz ./vaultwarden/

# Backup Nextcloud
tar -czf $BACKUP_DIR/nextcloud-$DATE.tar.gz ./nextcloud/

# Backup Immich
tar -czf $BACKUP_DIR/immich-$DATE.tar.gz ./immich/

# Keep last 30 days
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
```

## Next Steps and Learning Path

### Phase 1: Foundation (This Workshop)
- Deploy core services
- Learn Docker Compose
- Understand networking and security

### Phase 2: Expansion (Next)
- Add storage services (Nextcloud, Immich)
- Set up media server
- Implement monitoring

### Phase 3: Advanced
- Kubernetes for container orchestration
- High availability setup
- Advanced networking (VLANs, firewall rules)
- CI/CD pipelines

### Phase 4: Mastery
- Automated deployments
- Infrastructure as code (Terraform for entire stack)
- Disaster recovery procedures
- Capacity planning and scaling

## Community Resources

**Reddit Communities:**
- r/homelab - General homelab discussion
- r/selfhosted - Self-hosted services
- r/docker - Docker-specific

**Websites:**
- Awesome-Selfhosted (GitHub) - Curated list of services
- Linuxserver.io - Pre-configured Docker images
- TechnoTim (YouTube) - Homelab tutorials

**Documentation:**
- Docker Compose docs: https://docs.docker.com/compose/
- Individual service documentation links below

## Service Documentation Links

- **Immich:** https://immich.app/
- **Nextcloud:** https://nextcloud.com/
- **Jellyfin:** https://jellyfin.org/
- **Uptime Kuma:** https://uptime.kuma.pet/
- **Gitea:** https://gitea.io/
- **Home Assistant:** https://www.home-assistant.io/
- **Syncthing:** https://syncthing.net/
- **Grafana:** https://grafana.com/
- **Prometheus:** https://prometheus.io/

## Key Takeaways

1. **Start small:** Core services first, add complexity gradually
2. **Choose based on needs:** Don't deploy everything "just because"
3. **Organize with compose:** Use multiple compose files for clarity
4. **Monitor resources:** Know what your hardware can handle
5. **Backup regularly:** Your data is precious
6. **Join communities:** Learn from others' experiences
7. **Document everything:** Future you will appreciate it
8. **Iterate:** Your homelab will evolve over time

Your homelab is now ready for expansion. Choose services that solve your real problems, and build from there. The beauty of a homelab is that it's completely customizable to your needs.

Happy homelabbing!
