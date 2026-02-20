# Getting Started with Your Homelab

## Homelab Journey Roadmap

Building a homelab is not a single event but an evolving journey. Most successful homelab builders follow a progression:

```
Start Small → Learn Fundamentals → Expand Services → Add Redundancy → Scale Infrastructure
```

### Stage 1: Start Small (Month 1)
- **Hardware:** Single computer or laptop
- **Goal:** Learn basic Linux, Docker, and containerization
- **Services:** AdGuard Home, one or two simple services
- **Time investment:** 10-20 hours
- **Skills developed:** Linux fundamentals, container basics

### Stage 2: Learn Fundamentals (Months 2-3)
- **Hardware:** Single dedicated machine
- **Goal:** Understand networking, storage, and basic infrastructure
- **Services:** DNS, media server, basic web services
- **Time investment:** 20-40 hours
- **Skills developed:** Networking, DNS, containerization, backup basics

### Stage 3: Expand Services (Months 4-6)
- **Hardware:** 2 machines or 1 powerful machine with VMs
- **Goal:** Run multiple services simultaneously
- **Services:** 20-40 different applications and services
- **Time investment:** 40-80 hours
- **Skills developed:** Service integration, Docker Compose, basic automation

### Stage 4: Add Redundancy (Months 7-12)
- **Hardware:** 3+ machines, shared storage
- **Goal:** Services survive single machine failure
- **Services:** Everything from stage 3, now with HA
- **Time investment:** 80-160 hours
- **Skills developed:** Clustering, high availability, disaster recovery

### Stage 5: Scale Infrastructure (Year 2+)
- **Hardware:** 5+ machines, professional storage, advanced networking
- **Goal:** Production-like environment with monitoring and alerting
- **Services:** 100+ containers, complex applications, development CI/CD
- **Time investment:** 160+ hours
- **Skills developed:** Advanced infrastructure, Kubernetes, automation, monitoring

## Different Approaches: Single Machine vs Cluster

### Single Machine Homelab

**Good for:**
- Budget-conscious builders ($300-500)
- Learning fundamentals without overwhelming complexity
- Casual self-hosting needs
- Testing and experimentation
- People with limited space

**Hardware options:**
- Used mini PC ($200-400)
- NUC ($400-800)
- Raspberry Pi 4 ($50-100, limited)
- Repurposed laptop or desktop

**Pros:**
- Lower initial cost
- Single point of failure is acceptable for learning
- Simpler networking setup
- Lower power consumption
- Easier to maintain and troubleshoot
- Perfect for learning

**Cons:**
- Services go down if machine needs maintenance
- Limited resources for running many services
- Can't learn clustering and HA concepts
- Slower performance with many simultaneous services
- Storage limitations without external drives

**Realistic expectations:**
- Run 20-40 Docker containers comfortably
- 1-2 virtual machines if needed
- Peak performance: running 10-15 services simultaneously
- Not suitable for production-critical services

### Two-Node Cluster

**Good for:**
- Intermediate builders ($600-900)
- Wanting redundancy and learning clustering
- Better performance than single machine
- Testing HA configurations

**Pros:**
- Can handle one node going down without total service loss
- Learn basic clustering concepts
- Better performance through distribution
- Moderate cost increase

**Cons:**
- Still risky for truly critical services (both nodes could fail)
- More complex to troubleshoot
- More networking knowledge required
- Network still represents single point of failure

### Three-Node Cluster (Recommended for This Workshop)

**Good for:**
- Serious hobbyists ($900-1500)
- Learning production-like infrastructure
- Running genuinely reliable services
- Building portfolio-worthy projects

**Pros:**
- Survives any single node failure
- Learn real clustering and distributed systems
- Can run 100+ services reliably
- Closely mirrors professional setups
- Excellent learning platform for career advancement
- Scales knowledge to larger deployments

**Cons:**
- Higher initial cost
- More complex setup and maintenance
- More networking required
- Power consumption higher

**This workshop uses 3-node cluster because:**
- You learn fault tolerance from day one
- Reflects real-world infrastructure patterns
- Cost is still reasonable (~$900 total)
- Provides genuine redundancy for personal services
- Excellent learning platform for professional skills

### Four or More Nodes

**Good for:**
- Advanced users wanting high availability
- Running Kubernetes and complex orchestration
- Building production-like environments
- Serious self-hosting enthusiasts

**Considerations:**
- Cost increases significantly
- Management complexity increases
- Space and cooling requirements grow
- Power consumption becomes notable

## Budget Considerations

### The Budget Spectrum

#### Minimal Budget: $100-300
**Start with:**
- Used Raspberry Pi 4 (8GB) - $80
- Or used mini PC - $150-300

**Realistic setup:**
- Learn Linux and Docker
- Run 5-15 lightweight services
- Low power consumption
- Limited expansion

**Upgrade path:**
- Add a second Pi or mini PC
- Add external USB storage
- Grow to 2-3 machine setup

#### Moderate Budget: $400-800
**Start with:**
- Single used mini PC - $300-400
- Managed switch - $50-100
- External storage - $100-200

**Realistic setup:**
- Run 30-50 Docker containers
- 2-3 virtual machines
- Comfortable for most services
- Better performance than single Pi

**Upgrade path:**
- Add second and third mini PC later
- Upgrade storage gradually
- Add NAS when budget allows

#### Intermediate Budget: $800-1500
**Start with:** (This workshop's approach)
- 1x master mini PC - $400
- 2x worker mini PCs - $500
- Network switch and cabling - $50-100
- UPS backup - $100

**Realistic setup:**
- 100+ Docker containers
- 10-20 virtual machines
- Full clustering and HA
- 24TB+ storage capability
- Fault-tolerant operations

**Upgrade path:**
- Add 4th-6th nodes
- Upgrade to managed switch
- Add dedicated NAS
- Professional monitoring and alerting

#### Advanced Budget: $1500-5000+
**Start with:**
- Multiple powerful mini PCs or small servers - $1500-3000
- Professional managed switch - $300-800
- Dedicated NAS - $500-1500
- Professional UPS - $200-400
- Rack and accessories - $200-400

**Realistic setup:**
- 200+ Docker containers
- Complex Kubernetes clusters
- Multiple redundant storage pools
- Advanced networking with VLANs and firewalls
- Professional monitoring, logging, alerting
- Development CI/CD pipelines
- Multiple independent services and environments

## Space and Power Requirements

### Physical Space

**Single Machine (laptop or mini PC):**
- Desk space: 6" × 4" × 2" (shoebox-sized)
- Can sit on shelf or desk
- Cables: power, network (very minimal)
- Fan noise: whisper-quiet

**Two-Three Machine Setup:**
- Shelf space: 18" × 12" × 6"
- Small wall-mounted shelf or desk area
- More cables to manage (networking, power distribution)
- Fan noise: quiet, barely noticeable
- Network switch: additional 12" × 4" × 2"

**Four-Plus Machines:**
- Desk dedicated or small shelf unit
- Cable management becomes important
- Consider small rack (6-12U) for organization
- Fan noise: combined effect, may need room ventilation

**Our Workshop Setup:**
- 3 mini PCs: ~6" × 4" × 2" each
- 1 switch: ~12" × 4" × 2"
- 1 UPS: ~15" × 6" × 6"
- 1 NAS (if added): ~8" × 6" × 6"
- **Total footprint:** ~2 square feet of shelf space
- Can fit on single bookshelf or small desk

### Power Consumption and Cooling

#### Idle Power (24/7 baseline, nothing running)
- Single mini PC: 15-25W
- 3-node cluster: 45-60W
- Network equipment: 10-15W
- **Total idle:** ~70-90W

#### Typical Power (normal usage with 50% CPU/Memory)
- Single mini PC: 30-60W
- 3-node cluster: 120-180W
- Network equipment: 10-15W
- **Total typical:** ~135W per our design

#### Heavy Load (heavy VMs/containers, intensive tasks)
- Single mini PC: 60-100W
- 3-node cluster: 200-280W
- Network equipment: 10-15W
- **Total heavy:** ~220-280W

#### Maximum Power (all cores pegged, peak I/O)
- 3-node cluster maximum: ~280W
- With UPS: ~330W

**Cost Analysis:**
- Assuming $0.12 per kWh average US electricity rate
- 3-node cluster at 135W average × 24 hours × 365 days = 1,183 kWh/year
- Annual cost: 1,183 kWh × $0.12 = **$142/year**
- That's about **$12/month** for a fully functional homelab

**Cooling Requirements:**
- Mini PCs are designed for fanless or near-silent operation
- Heat dissipation in typical room: passive or single 120mm fan
- No special cooling required for residential setups
- Small 60W space heater worth of heat output
- Ambient room temperature increase: <2-3°F with 3 machines
- No air conditioning increase needed in most climates

**Environmental Impact:**
- 1,183 kWh/year = carbon footprint of ~1 ton CO2 (US average grid)
- Offset by renewable energy options, or lower consumption with modern hardware

## Skills You'll Need and Learn

### Prerequisites (Nice to Have)

These help but aren't required - we'll teach you:

**Linux Familiarity**
- Basic command-line comfort
- Understanding of file permissions
- Ability to edit configuration files with nano/vi

**Networking Basics**
- What IP addresses and subnets are
- TCP/IP concepts at high level
- DHCP and DNS concepts

**General IT Knowledge**
- How to Google error messages (essential!)
- Basic troubleshooting methodology
- Patience with things not working first try

### Skills You'll Develop

#### Linux and System Administration
- Linux command-line mastery
- User and permission management
- System service management with systemd
- System monitoring and logs
- Package management and updates
- Storage and filesystem concepts
- Backup and recovery procedures

#### Containerization and Application Deployment
- Docker fundamentals and best practices
- Docker Compose for multi-container applications
- Container networking and volumes
- Image building and optimization
- Container orchestration basics
- Application troubleshooting

#### Virtualization
- Virtual machine creation and management
- Resource allocation and optimization
- Snapshots and cloning
- Storage configuration for VMs
- Performance tuning

#### Networking
- IP addressing and subnetting
- VLAN configuration and management
- Static and dynamic IP assignment
- DNS setup and management
- Firewall rules and security
- Network monitoring and troubleshooting
- VPN setup and management

#### Infrastructure as Code
- Terraform for infrastructure automation
- Ansible for configuration management
- Version control with Git
- GitOps practices
- Infrastructure testing

#### Monitoring and Observability
- Prometheus metrics collection
- Grafana dashboards and visualization
- Log aggregation with ELK or Loki
- Alert configuration and management
- System performance analysis

#### High Availability and Disaster Recovery
- Clustering and failover
- Data replication and synchronization
- Backup strategies and testing
- Recovery procedures
- Capacity planning

#### Security
- Authentication and authorization
- Network segmentation with VLANs
- Firewall configuration
- Certificate management (SSL/TLS)
- Vulnerability scanning
- Access control and auditing

## Common Mistakes Beginners Make

### Mistake 1: Undersizing Hardware Initial Purchase

**What happens:** Buy single weak machine, quickly outgrow it, frustrated with performance.

**How to avoid:**
- Budget for 3 nodes upfront if possible (total cost still under $1000)
- If single machine, pick mid-range specs (6+ cores, 16GB RAM minimum)
- Better to have spare capacity than to be constrained
- Consider used/refurbished enterprise equipment for better specs/price

**Better approach:** Buy right the first time. A $900 3-node setup is better than a $300 single machine followed by $1200 in upgrades.

### Mistake 2: Ignoring Network Design

**What happens:** Just use WiFi, assume flat network, later can't isolate IoT or guest traffic.

**How to avoid:**
- Use wired Ethernet from day 1 (critical for reliability)
- Plan VLAN design even for small setup
- Proper DNS configuration with Ad blocking
- Firewall rules between network segments

**Better approach:** Network design is foundational. Spend time getting it right early.

### Mistake 3: Running Services Directly on Hypervisor

**What happens:** Tightly coupled system, hard to backup, hard to migrate, security issues.

**How to avoid:**
- Use containers or VMs for all services
- Never run services directly on Proxmox host
- Keep host OS clean and minimal
- This enables portability and resilience

**Better approach:** Containers/VMs from day 1. Worth learning Docker properly.

### Mistake 4: No Backup Strategy

**What happens:** Disk fails, years of configuration gone, weeks of recovery work.

**How to avoid:**
- Backup strategy on day 1, not after failure
- Use 3-2-1 rule: 3 copies, 2 different media types, 1 offsite
- Automated backups
- Regular restore testing

**Better approach:** Automated daily backups to external storage. Test monthly.

### Mistake 5: Ignoring Power/Cooling

**What happens:** Machines overheat, shut down during peak use, degraded performance.

**How to avoid:**
- Adequate ventilation around equipment
- UPS for graceful shutdown on power loss
- Monitor temperatures
- Proper airflow management

**Better approach:** UPS is essential ($100), proper shelf ventilation is free.

### Mistake 6: Too Many Services at Once

**What happens:** Overwhelmed with configuration, services interact badly, unable to troubleshoot.

**How to avoid:**
- Start with 3-5 core services (DNS, reverse proxy, one self-hosted app)
- Add services incrementally
- Master service X before learning service Y
- Document configuration as you go

**Better approach:** Focus and depth beats breadth. 5 well-configured services beats 20 poorly configured ones.

### Mistake 7: No Documentation or Version Control

**What happens:** Months later, can't remember why configuration is set that way, afraid to change anything.

**How to avoid:**
- Keep all configurations in Git
- Document why decisions were made
- Use Infrastructure as Code (Terraform, Ansible)
- Comments in configuration files

**Better approach:** Everything in version control. Treat homelab like production code.

### Mistake 8: Inadequate Monitoring

**What happens:** Service silently fails, you don't notice for days, data is lost.

**How to avoid:**
- Simple monitoring/alerting from the start
- Know immediately when services are down
- Monitor disk space, memory, CPU, network
- Trending and capacity planning

**Better approach:** Prometheus + Grafana is free and essential. Set up on day 1.

### Mistake 9: Treating Homelab as Production

**What happens:** Spend all time maintaining, never have time to experiment or learn.

**How to avoid:**
- Accept that downtime happens and is OK
- Don't let perfect be enemy of good
- It's OK to break things and fix them
- Treat it as a learning environment

**Better approach:** Homelab is for learning. Occasional downtime is fine. Use staging for testing.

### Mistake 10: Ignoring Security Until Later

**What happens:** Exposed services, weak passwords, compromised machines, regret.

**How to avoid:**
- Security from day 1, not an afterthought
- Strong authentication (2FA where possible)
- Network segmentation with VLANs
- Regular updates and patching
- Firewall rules and access control

**Better approach:** Security is fundamental. A few hours upfront saves weeks of remediation.

## Recommended Starting Points for Different Budgets

### If You Have $100-300: Start Ultra Minimal

**Hardware:**
- Raspberry Pi 4 8GB ($80-100) or used mini PC ($150-300)
- USB SSD for storage ($40-60)
- USB power supply (you likely have one)
- Ethernet cable (you likely have one)

**Initial Setup:**
1. Install Ubuntu or Debian
2. Learn Linux basics and Docker
3. Run AdGuard Home for ad blocking
4. Run one other service (Nextcloud, Plex, etc.)

**Timeline:** 20-30 hours to get comfortable
**Upgrade path:** Add second Pi, add managed switch, scale from there

### If You Have $400-800: Start Single Powerful Machine

**Hardware:**
- Used mini PC with 6+ cores, 16GB RAM ($300-400)
- 1TB NVMe SSD (included or add $80)
- Managed 8-port switch ($50-80)
- UPS backup power ($80-100)
- Cables and networking ($30)

**Initial Setup:**
1. Install Proxmox or Ubuntu
2. Learn hypervisor/container fundamentals
3. Run 5-10 core services
4. Set up monitoring
5. Plan expansion to 3 nodes

**Timeline:** 40-60 hours to master
**Upgrade path:** Add two more mini PCs, create 3-node cluster

### If You Have $800-1500: Start 3-Node Cluster (This Workshop)

**Hardware:**
- 1x Master mini PC with 6+ cores, 32GB RAM ($400)
- 2x Worker mini PCs with 6+ cores, 16GB RAM each ($500)
- Managed 8-port switch ($60-100)
- UPS backup power ($100)
- DAS storage with 3x 8TB drives ($400) [optional phase 2]
- Cables, rack, accessories ($50-100)

**Initial Setup (Phase 1):**
1. Network design with VLANs
2. Install Proxmox 3-node cluster
3. Configure local storage initially
4. Deploy core services with HA
5. Set up monitoring and backups

**Phase 2 (Month 2-3):**
1. Add shared storage (NFS or Ceph)
2. Migrate services to use shared storage
3. Implement automated backups
4. Add more complex services

**Timeline:** 80-120 hours over 2-3 months
**Upgrade path:** Add nodes 4-6, upgrade to managed storage, build Kubernetes, etc.

### If You Have $1500-5000+: Start with Advanced Setup

**Hardware:**
- Multiple powerful mini PCs or small servers ($1500-3000)
- Professional managed switch ($300-800)
- Dedicated NAS or SAN ($500-1500)
- Professional UPS ($200-400)
- Rack and cooling ($200-400)

**Setup Strategy:**
- Don't try to use everything at once
- Implement core infrastructure first
- Add professional services gradually
- Build monitoring and HA from day 1
- Plan for 200+ services from start

**Timeline:** 160+ hours over 3-6 months
**Outcome:** Production-grade homelab with professional-level capabilities

## Next Steps

You've learned the journey progression and budgeting. Next, let's look at the specific hardware for this workshop's 3-node cluster.

**Continue to:** [Session 1.3: Hardware Selection and Specifications](./03-hardware-selection.md)
