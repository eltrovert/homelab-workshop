# What is a Homelab?

## Definition and Concept

A **homelab** is a personal computing environment where you build, configure, and manage your own IT infrastructure at home. It's a private cluster of computers, servers, networking equipment, and storage that allows you to run services and applications under your complete control.

Unlike relying on cloud providers or managed services, a homelab gives you:
- **Physical ownership** of the hardware
- **Full control** over the infrastructure
- **Complete privacy** of your data
- **Learning opportunities** through hands-on experience

Think of it as a miniature data center in your home, where you're responsible for everything from hardware procurement to network configuration to software maintenance.

## Why Build a Homelab?

### Learning and Skill Development

Building a homelab is one of the best ways to learn real IT and infrastructure concepts:
- Understand how Linux systems work at scale
- Learn containerization with Docker and Kubernetes
- Master virtualization with Proxmox or ESXi
- Develop network administration skills
- Practice automation with Terraform, Ansible, and other IaC tools
- Gain hands-on experience with monitoring, logging, and alerting

These skills are directly applicable to professional environments and highly valued in the job market.

### Self-Hosting and Privacy

Run your own services instead of relying on cloud providers:
- **Password manager** - control your own Bitwarden or Vaultwarden instance
- **Photo storage** - self-hosted Nextcloud instead of Google Photos
- **Email** - full control with Mailcow or iRedMail
- **Social media alternatives** - run Mastodon or Pixelfed
- **Document storage** - Nextcloud or Synology
- **Backup solutions** - redundant storage without cloud dependency

All your data remains under your roof and under your control.

### Career Development

Your homelab becomes a portfolio of work:
- Demonstrate real infrastructure knowledge to employers
- Practice problems you encounter in professional environments
- Build projects to showcase in interviews
- Stay current with modern DevOps and cloud-native technologies
- Develop troubleshooting and problem-solving skills

### Cost Efficiency

Over time, a homelab can save significant money:
- Run unlimited services without per-user fees
- No monthly cloud service subscriptions
- One-time hardware investment covers years of operation
- Typical cost to build a capable 3-node cluster: $800-1200
- Monthly operating cost: $10-30 (electricity, internet)

Compared to AWS, Azure, or Google Cloud, this is extremely economical for always-on services.

### Independence and Reliability

Operating your own infrastructure means:
- Services don't disappear if a company pivots or shutdowns
- No vendor lock-in to cloud providers
- Custom configurations tailored to your specific needs
- Services remain available even during internet outages (mostly)
- You understand your entire technology stack

### Fun and Creativity

Building and tinkering with technology is genuinely enjoyable:
- Experiment with new technologies without risk
- Build creative projects and automation
- Join an engaged community of homelab enthusiasts
- Customize your infrastructure exactly as you want
- Continuous learning keeps your mind engaged

## Common Homelab Use Cases

### Media Server
Store and stream your personal media collection:
- **Plex** or **Jellyfin** - movie and TV show streaming
- **Sonarr/Radarr** - automated media management
- **Transmission/qBittorrent** - torrent clients for legal content
- **Music Subsonic/Navidrome** - personal music streaming
- Typical storage: 50TB-500TB depending on library size

### DNS and Ad Blocking
Control DNS resolution across your entire network:
- **AdGuard Home** - block ads and tracking at the DNS level
- **Pi-hole** - popular alternative with great web interface
- **Unbound** - private recursive DNS resolver
- Block thousands of ad domains automatically
- Gain insight into network traffic patterns

### VPN and Secure Remote Access
Access your homelab services securely from anywhere:
- **WireGuard** - modern, fast, secure VPN protocol
- **OpenVPN** - widely compatible VPN solution
- **Tailscale** - zero-trust mesh VPN network
- **Nextcloud Remote Desktop** - secure remote access
- Encrypt all traffic to/from your homelab

### Smart Home Automation
Centralize and control your smart home:
- **Home Assistant** - open-source home automation platform
- **Node-RED** - visual automation workflows
- **Mosquitto** - MQTT message broker for IoT devices
- Local control without cloud dependencies
- Create complex automations and routines

### Development Environment
Full development infrastructure at home:
- Git repository hosting with Gitea or GitLab
- CI/CD pipelines with Jenkins, GitLab CI, or Gitea Actions
- Database servers (PostgreSQL, MySQL, MongoDB)
- Staging environments matching production
- Development tool suites (IDEs, debuggers, profilers)

### NAS and Backup Storage
Reliable data storage and redundancy:
- **TrueNAS** - professional NAS with ZFS
- **Unraid** - flexible storage with parity protection
- **Ceph** - distributed storage across nodes
- RAID configurations for redundancy
- Automated backup scheduling and verification

### Application and Web Hosting
Host web applications and services:
- Personal blogs with Ghost or WordPress
- Photo galleries with Immich or Pixelfed
- Project management with Plane or OpenProject
- Monitoring and alerting with Prometheus and Grafana
- Container orchestration with Docker Swarm or Kubernetes

### Testing and Experimentation
Safe environment for trying new technologies:
- Test new Linux distributions before production use
- Experiment with Kubernetes concepts
- Learn infrastructure-as-code with Terraform
- Practice disaster recovery procedures
- Test new software versions safely

## Homelab vs Cloud Services

### Cost Comparison Over Time

| Scenario | Cloud (AWS) | Homelab |
|----------|-----------|---------|
| Small droplet (1 vCPU, 1GB RAM) | $5/month × 12 = $60/year | One-time $150 (shared across many services) |
| Development environment with DB | $100-200/month × 12 = $1,200-2,400/year | Included in homelab hardware |
| 10TB storage with redundancy | ~$200-300/month × 12 = $2,400-3,600/year | $150-300 one-time hardware cost |
| 3-year total cost for typical setup | $4,000-8,000 | $800-1,500 (one-time) + $360-1,080 electricity |

**Homelab advantage:** After 1-2 years, the homelab becomes dramatically more cost-effective.

### Cloud Advantages

Despite the cost benefits, cloud services have advantages:
- Zero hardware maintenance burden
- Geographic redundancy and failover
- Automatic scaling for traffic spikes
- Professional SLA and support
- No electricity or space concerns
- Focus on application rather than infrastructure

**Best practice:** Use homelab for learning and personal services, use cloud for production applications requiring SLAs.

### Privacy and Data Control

| Aspect | Cloud | Homelab |
|--------|-------|---------|
| Data location | Provider's data centers | Your location |
| Access to data | Provider and authorities | Only you |
| Terms changes | Provider can change anytime | Never change (you own it) |
| Data usage for ML/analytics | Possible | Under your control |
| Compliance requirements | Provider's choice | Your responsibility |

### Learning Value

**Cloud:** You learn through using managed services and APIs. You don't understand underlying infrastructure.

**Homelab:** You learn everything - from hardware selection to network configuration to container orchestration. You understand the entire stack.

## Who Is This Workshop For?

### Perfect For:
- **Linux enthusiasts** wanting deeper system knowledge
- **DevOps/SRE professionals** practicing infrastructure skills
- **Software developers** building complete environments for testing
- **Privacy-conscious users** wanting control over personal data
- **Tech hobbyists** enjoying hands-on tinkering
- **Students** learning IT infrastructure concepts
- **Career changers** building practical IT experience
- **Self-hosters** wanting to escape cloud dependency

### Helpful Prerequisites:
- Basic Linux command-line comfort (we'll teach you more)
- Comfort with networking concepts like IP addresses and VLANs
- Willingness to learn and troubleshoot
- Patience for things not working immediately
- About 20-40 hours for initial setup and learning

### Still Valuable Even If You're:
- **Complete Linux beginner** - this workshop teaches fundamentals
- **Mac/Windows only user** - VirtualBox or Docker Desktop can help you learn
- **Cloud-native developer** - homelab teaches the infrastructure that powers the cloud
- **System administrator** - hands-on experience you can't get otherwise
- **Just curious** - homelabs are fun and educational regardless of background

## Real-World Examples

### What You Can Actually Run

Here's a realistic example of services running on a 3-node, 64GB RAM homelab:

**Containerized Services (80-100 running containers):**
- AdGuard Home (DNS/adblocking)
- Nextcloud (file sync and sharing)
- Home Assistant (smart home automation)
- Plex (media server)
- Jellyfin (alternative media server)
- Unifi Controller (network management)
- Prometheus + Grafana (monitoring)
- Gitlab Community (git repository)
- Gitea (lightweight git)
- Immich (photo management)
- Vaultwarden (password manager)
- Navidrome (music streaming)
- RSS readers and news aggregators
- Various development and testing environments

**Virtual Machines:**
- Ubuntu/Debian testing instances
- Windows 10 for specific testing
- Various service instances
- Backup and recovery testing VMs

**Storage:**
- 24TB usable storage across redundant array
- Automatic backups of critical data
- Media library hosting
- Archive storage

**Performance:**
- Typical cluster utilization: 30-50%
- Response times: <100ms for most services
- Power consumption: ~135W typical, ~280W maximum
- Silent operation (mini PCs are quiet)

### Why This Approach

This workshop uses a 3-node Proxmox cluster because it:
- Teaches clustering concepts you'll see in professional environments
- Provides redundancy so one node failure doesn't take down everything
- Is cost-effective compared to buying separate computers
- Uses modern hypervisor technology (Proxmox)
- Scales knowledge to larger deployments
- Keeps total cost reasonable (~$900)
- Teaches you real-world infrastructure practices

## Next Steps

You now understand what a homelab is and why it's valuable. The next step is determining if one is right for you and what size to start with.

**Continue to:** [Session 1.2: Getting Started with Your Homelab](./02-getting-started.md)
