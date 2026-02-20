# Hardware Selection and Specifications

## Hardware Categories and Trade-offs

Building a homelab starts with choosing the right hardware foundation. Let's examine the major categories and why we chose what we did.

### Enterprise Servers (Dual Socket 1U Rack Servers)

**Examples:** Dell PowerEdge R610/R620/R640, HP ProLiant DL380, Lenovo ThinkSystem SR590

**Specifications:**
- Dual 8-14 core processors (16-28 cores total)
- 32-512GB RAM capacity
- 8+ drive bays for storage
- 10GbE networking
- Professional management (iDRAC/iLO)

**Pros:**
- Maximum performance and capacity
- Professional hardware features (redundant PSU, IPMI)
- Easy to expand storage
- Enterprise-grade reliability

**Cons:**
- **Very loud** (jet engine sounds, 70-90dB)
- **High power consumption** (600-1200W each)
- Large form factor (rack mount only)
- Professional cooling required
- Expensive electricity bills ($50-100/month)
- Overkill for home use
- Hard to fit in home quietly

**Use case:** Not suitable for residential homelabs due to noise and power consumption. Better for garage-based labs or data center environments.

**Cost:** $500-2000 used, $3000+ new

### Mini PCs and NUCs (Our Choice)

**Examples:** Lenovo ThinkCentre M920q, Dell OptiPlex 3060, Intel NUC, Beelink, Giada

**Specifications:**
- 4-8 core processors (single socket)
- 8-32GB RAM
- M.2 NVMe SSD storage
- 1GbE networking (some with 2.5GbE)
- Fanless or near-silent operation
- Compact form factor (6" × 4" × 2")

**Pros:**
- **Extremely quiet** (near silent)
- **Low power consumption** (45-90W typical)
- Compact form factor
- Good performance for Docker/containers
- Reasonable cost for capabilities
- Easy to add redundancy (3 nodes = $900)
- Fits easily in home environment
- Very reliable for years of operation

**Cons:**
- Cannot easily upgrade hardware (CPUs soldered)
- Limited storage expansion (usually 1 SSD)
- Limited RAM expansion (some models, but not all)
- Not suitable for large-scale storage arrays
- No redundant power supplies (covered by UPS)
- Single network port (need switch)

**Use case:** Perfect for home homelabs, especially 3+ node clusters. Best balance of performance, cost, noise, and power.

**Cost:** $200-500 used (our focus), $400-1000 new

### Single Board Computers (Raspberry Pi, Orange Pi)

**Examples:** Raspberry Pi 4/5, Orange Pi, Rockchip boards, Jetson Nano

**Specifications:**
- 4-8 core ARM processors (not x86)
- 4-8GB RAM
- MicroSD or NVMe SSD storage
- 1GbE networking (sometimes USB bottlenecked)
- Tiny form factor
- Very low power (5-15W)

**Pros:**
- Extremely low cost ($50-150)
- Tiny form factor
- Very low power consumption
- Large community and tutorials
- Good for learning basics

**Cons:**
- **ARM architecture** - not all software is compatible
- **Slow performance** compared to x86
- Storage bottlenecks (MicroSD is very slow)
- RAM limitations
- Not suitable for running many services
- Limited expansion options
- Harder to scale to clusters

**Use case:** Great for learning Linux basics and Docker fundamentals. Limited for serious homelab work.

**Cost:** $50-150 per board

### High-Performance NUCs and Small Servers

**Examples:** Intel NUC Pro, Supermicro A+ server, Asrock NUC system

**Specifications:**
- 6-12 core processors
- 32-64GB RAM
- Multiple NVMe slots
- Professional I/O options
- Better cooling solutions

**Pros:**
- Good performance for demanding workloads
- Some have better upgrade options
- Professional-grade reliability

**Cons:**
- Higher cost ($600-1500)
- Diminishing returns for homelab use
- Overkill for most home services
- Still limited compared to servers

**Use case:** If you have higher budget, these are good. But mini PCs are better value.

**Cost:** $600-1500

## Why Mini PCs Are the Sweet Spot

For the vast majority of homelabs, mini PCs represent the optimal balance:

### Performance-to-Wattage Ratio
- Mini PC at full load: ~70W for 6 cores
- Server at full load: ~300W for similar cores
- That's 4x more power-efficient

### Noise Levels
- Mini PC: 15-25dB (barely audible, like quiet fan)
- NUC: 20-30dB (whisper quiet)
- Server: 70-90dB (like vacuum cleaner)
- You can put mini PCs on your desk without annoyance

### Cost Efficiency
- Mini PC: $300-400 for 6-core, 32GB used
- Server: $1000-2000 for similar specs used
- 3 mini PCs cluster: $900-1200
- Equivalent server cluster: $3000-6000+

### Real Estate
- 3 mini PCs: ~6 inches × 4 inches × 6 inches total
- Fits on a bookshelf or small desk
- Servers: Require dedicated rack space

### Power Consumption and Cooling
- Mini PCs: 45W idle, 135W typical (at home comfort level)
- Can use normal home electricity circuit
- No special cooling required
- Fan doesn't work harder with higher room temperature

### Reliability
- Mini PCs designed for 24/7 operation
- 5+ year lifespan typical
- Industrial-grade capacitors
- Tested in enterprise environments before consumer models
- Used refurbished units with known reliability

## Our Workshop Hardware Breakdown

This workshop uses a specific, real 3-node cluster because these are real machines that work well and are achievable cost.

### Master Node: Lenovo ThinkCentre M920q

**Specifications:**
- **Processor:** Intel Core i7-8700T (6 cores, 12 threads)
  - Base clock: 2.4 GHz
  - Turbo clock: 4.0 GHz
  - TDP: 35W (very efficient)
- **RAM:** 32GB DDR4-2666
- **Storage:** 512GB NVMe SSD (fast Proxmox boot)
- **Network:** Intel 1GbE NIC
- **Form Factor:** 3.9" × 3.8" × 1.5" (ultra-compact)
- **Power:** 90W max, 45W typical

**Why Master?**
- More RAM (32GB) for running management services
- Larger SSD for Proxmox and local VMs
- Runs Proxmox management console
- Runs shared services (DNS, reverse proxy, monitoring)
- No downtime, no reboots (reliability priority)

**Cost:** $350-450 used (2023-2024 pricing)

### Worker Nodes (x2): Dell OptiPlex 3060 Micro

**Specifications (Each):**
- **Processor:** Intel Core i5-8500T (4 cores, 8 threads)
  - Base clock: 2.1 GHz
  - Turbo clock: 3.5 GHz
  - TDP: 35W (efficient)
- **RAM:** 16GB DDR4-2666
- **Storage:** 256GB NVMe SSD
- **Network:** Intel 1GbE NIC
- **Form Factor:** 7.2" × 6.8" × 1.6" (micro desktop)
- **Power:** 75W max, 40W typical

**Why These?**
- Cost effective ($200-250 each used)
- Proven reliability
- Good performance for their cost
- Can tolerate individual node failure
- Easy to find and replace

**Cost:** $200-300 each used = $400-600 for pair

### Network Switch: TP-Link LS108G

**Specifications:**
- **Ports:** 8 × 1GbE RJ45 Ethernet
- **Type:** Unmanaged (no VLAN support... we'll upgrade)
- **Power:** 4W passive, no active cooling
- **Backplane:** 16 Gbps full duplex
- **Latency:** <4.1 microseconds

**Why This Initially?**
- Budget option ($20-40)
- Gets you started quickly
- Perfect for learning
- No configuration needed to start

**Upgrade Path:**
- Move to managed switch for VLAN support ($60-150)
- Enables proper network segmentation
- Support for managed features (port monitoring, etc.)

**Cost:** $25-40

### UPS: APC BVX1200LIMS

**Specifications:**
- **Capacity:** 1200VA / 600W
- **Runtime:** ~15 minutes at half load
- **Outlets:** 8 total (4 battery backup, 4 surge only)
- **Network:** RJ45 management port
- **Battery:** Lead-acid (typical UPS battery)
- **Dimensions:** 5.5" × 5.5" × 7"

**Why UPS?**
- Graceful shutdown on power loss (Proxmox controlled halt)
- Prevent corruption of running VMs
- Protect drives from sudden power loss
- Uninterruptible service for brief outages

**Runtime Calculation:**
- Typical cluster draw: 135W
- UPS rating: 600W capacity, 1200VA
- At 135W draw: 600W ÷ 135W = ~4.4 hours capacity
- Actual runtime with UPS efficiency: 30-45 minutes
- Enough time for graceful shutdown or brief outage riding out

**Cost:** $100-150 used, $150-200 new

### Storage (Optional Phase 2): TerraMaster D4-320

**Specifications:**
- **Capacity:** 4-bay NAS chassis
- **Our Setup:** 3 × 8TB Seagate Exos X16 drives
- **Total:** 24TB raw, ~16TB after RAID5 parity
- **Interface:** Dual 1GbE Ethernet (can be bonded)
- **Power:** 40-60W typical
- **Form Factor:** Desktop form factor

**Why This Storage?**
- True redundancy across the cluster
- NFS export to all Proxmox nodes
- One drive can fail without data loss
- Shared storage enables live migration
- Professional-grade reliability drives (Seagate Exos series)

**Cost:** $400-600 (chassis) + $150-200/drive = $850-1200 total

**Note:** This is Phase 2. Start without shared storage, add when needed.

## Power Consumption Analysis

### Detailed Power Breakdown

```
POWER CONSUMPTION ANALYSIS (3-node cluster)

Idle State (machines on, nothing running):
  Master node:     20W
  Worker node 1:   18W
  Worker node 2:   18W
  Network switch:  4W
  UPS (overhead):  5W
  ───────────────
  Total idle:      65W

Typical State (running 50-70% CPU, VMs/containers active):
  Master node:     60W
  Worker node 1:   40W
  Worker node 2:   40W
  Network switch:  5W
  UPS:             5W
  ───────────────
  Total typical:   150W

Heavy Load (running heavy VMs, compiles, backups):
  Master node:     80W
  Worker node 1:   75W
  Worker node 2:   75W
  Network switch:  5W
  UPS:             5W
  ───────────────
  Total heavy:     240W

Maximum Spike (all cores pegged, all IO):
  Master node:     90W
  Worker node 1:   85W
  Worker node 2:   85W
  Network switch:  5W
  UPS:             10W
  ───────────────
  Total maximum:   275W

Note: UPS maximum output: 600W. We're never above 35% of capacity,
      so plenty of headroom for safety.
```

### Annual Operating Cost

**Assumptions:**
- US average: $0.12 per kWh
- Equipment operates 365 days per year
- Average consumption: 100W (accounting for day/night variation)

```
Calculation:
100W × 24 hours × 365 days = 876 kWh/year
876 kWh × $0.12 = $105/year ≈ $9/month

Compare to cloud:
  Single t3.medium AWS instance: $35/month = $420/year
  That's just ONE instance, we run 100+
```

### Thermal Characteristics

**Room Temperature Impact:**
- Heat output: 135W average = 461 BTU/hour
- Equivalent: Small space heater running 24/7
- Typical room size: 10' × 10' × 8' = 800 cubic feet
- Temperature rise: ~2-3°F in typical room
- Air conditioning cost: negligible

**Ventilation:**
- Mini PCs have intake vents on sides/front
- Warm air exits rear
- Recommended: 2-3 inches of clearance on sides
- Placement: On shelf with airflow, not in enclosed space

## Cost Breakdown Summary

### Hardware Costs (2023-2024 Market Prices)

| Component | Qty | Unit Cost | Total |
|-----------|-----|-----------|-------|
| Master Mini PC (i7, 32GB) | 1 | $400 | $400 |
| Worker Mini PC (i5, 16GB) | 2 | $250 | $500 |
| TP-Link Switch LS108G | 1 | $25 | $25 |
| UPS (APC 1200VA) | 1 | $120 | $120 |
| Ethernet Cables | 1 | $15 | $15 |
| Power Strips / PDU | 1 | $20 | $20 |
| Shelf / Mounting | 1 | $30 | $30 |
| **Total Infrastructure** | | | **$1,110** |
| | | | |
| *Optional Phase 2:* | | | |
| TerraMaster NAS Chassis | 1 | $500 | $500 |
| 8TB SAS Drives (x3) | 3 | $180 | $540 |
| **Total with Storage** | | | **$2,150** |

### Total Cost of Ownership (5 years)

| Component | Hardware | Electricity | Support | Total |
|-----------|----------|-------------|---------|-------|
| 5-year infrastructure cost | $1,110 | $525 | $0 | $1,635 |
| 5-year with storage | $2,150 | $525 | $0 | $2,675 |
| **Cost per month (infrastructure)** | | | | **$27.25** |
| **Cost per month (with storage)** | | | | **$44.58** |

**Compare to AWS for running equivalent services:**
- Single VM + storage: $100-200/month = $6,000-12,000 over 5 years
- Homelab: $27-45/month = $1,635-2,675 over 5 years
- **Homelab saves: $4,000-10,000** over 5 years
- Plus: You own the hardware, gain skills, maintain complete privacy

## Where to Buy Used Hardware

### eBay
- **Pros:** Wide selection, buyer protection, auction can get good deals
- **Cons:** Shipping heavy items expensive, seller quality varies
- **Tips:** Look for "Renewed" or "Like New" from business sellers, check return policy
- **Typical prices:** 10-20% below market rate

### Amazon Renewed
- **Pros:** Amazon's guarantee, consistent quality, free shipping on Prime
- **Cons:** Sometimes priced slightly higher, limited selection
- **Tips:** Check warehouse deals for additional discounts
- **Typical prices:** 15-25% below new

### Local Sources (Craigslist, Facebook Marketplace)
- **Pros:** Test before buying, no shipping, often negotiate price
- **Cons:** Limited selection, travel required, no buyer protection
- **Tips:** Meet in public, verify hardware before paying, test it
- **Typical prices:** 15-30% below market

### IT Recycling and Surplus Websites
- **Pros:** Business bulk liquidation, often very good prices
- **Cons:** Limited warranty, as-is sales, shipping expensive
- **Tips:** Look for "like new" condition, bulk orders can ship free
- **Typical prices:** 20-40% below market

### Tech Renewal Companies
- **Examples:** Back Market, Swappa, Decluttr
- **Pros:** Certified refurbished, guarantee, standardized pricing
- **Cons:** Price premium vs raw market, limited selection
- **Tips:** Use when quality/warranty matters more than price
- **Typical prices:** 10-15% below new

### Direct from Companies (Corporate Refresh)
- **Pros:** Bulk deals, can negotiate quantities
- **Cons:** Minimum orders, paperwork
- **Examples:** Dell/Lenovo refresh centers, IT liquidators
- **Tips:** Check Dell, Lenovo, HP official refurbished centers
- **Typical prices:** 20-35% below new

### Company IT Departments (Private Sales)
- **Pros:** Often below market, direct relationship
- **Cons:** Limited selection, specific to your area
- **Tips:** Network with local IT professionals, check bulletin boards
- **Typical prices:** 20-30% below market

## Pre-Purchase Checklist

Before buying hardware, verify:

**For Mini PCs:**
- [ ] CPU specs match (check generation, cores, TDP)
- [ ] RAM capacity (minimum 16GB for workers, 32GB for master)
- [ ] RAM type is DDR4 (DDR3 is older, limited upgrades)
- [ ] Storage included (256GB minimum for workers, 512GB for master)
- [ ] Storage is NVMe SSD (not SATA, not mechanical)
- [ ] Network card included (check model, should be 1GbE minimum)
- [ ] Power supply included
- [ ] No visible damage, corrosion, or broken ports
- [ ] Boots to BIOS/UEFI successfully
- [ ] Thermals are normal (not excessively hot)

**For Refurbished Units:**
- [ ] Check warranty period (minimum 30 days)
- [ ] Read seller feedback (>95% positive)
- [ ] Verify return policy
- [ ] Note cosmetic condition
- [ ] Check if drives are new or refurbished
- [ ] Power supply condition

**For Purchased Cluster:**
- [ ] All 3 machines have similar specs (no one slower)
- [ ] Test all nodes with Linux (Ubuntu live USB)
- [ ] Run hardware diagnostic tools (memtest, CPU burn test)
- [ ] Verify all nodes boot and network
- [ ] Test RAM with memtest for 1 pass minimum
- [ ] Verify BIOS supports virtualization (VT-x/AMD-V)
- [ ] Check CPU microcode is updated

**For Network Equipment:**
- [ ] All Ethernet cables included (at least 3)
- [ ] Switch power tested and working
- [ ] No visible port damage
- [ ] Can be plugged into power before cluster for testing

**For UPS:**
- [ ] Battery tested and working (LED indicators)
- [ ] Outlets are functional (test with lamp)
- [ ] Management cable working
- [ ] Rated for your power draw (our 600W adequate for 270W max)
- [ ] Runtime at your expected load is acceptable

## Hardware Comparison Table

| Aspect | Mini PC | NUC | SBC (Pi) | Server | Enterprise Server |
|--------|---------|-----|----------|--------|-------------------|
| **Cost per unit** | $250-400 | $300-800 | $50-150 | $1500+ | $2000+ |
| **Power consumption** | 40-90W | 50-100W | 5-15W | 200-400W | 600-1200W |
| **Noise level** | Very quiet | Quiet | Silent | Loud | Very loud |
| **Performance (6-core equiv)** | Excellent | Excellent | Moderate | Excellent | Excellent |
| **Storage expansion** | Limited | Limited | Limited | Excellent | Excellent |
| **RAM expansion** | Limited | Limited | Limited | Excellent | Excellent |
| **Architecture** | x86 | x86 | ARM | x86 | x86 |
| **Suitability for HA cluster** | Excellent | Excellent | Poor | Good | Excellent |
| **Home environment fit** | Perfect | Perfect | Good | Poor | Terrible |
| **Learning value** | Excellent | Excellent | Good | Good | High |
| **Scalability** | Excellent | Excellent | Limited | Good | Excellent |
| **Recommended use** | **Homelab clusters** | Budget-conscious | Learning | Not home | Not home |

## Why We Didn't Choose These Alternatives

### Why Not Raspberry Pi Cluster?
- **Architecture mismatch:** ARM not x86, many tools don't work
- **Performance floor:** Bottlenecks at storage and network
- **Not production-like:** Doesn't teach real infrastructure concepts
- **Storage problem:** MicroSD cards are too slow, NVMe adds complexity
- **Better for:** Learning Linux basics, IoT projects, specific ARM workloads

### Why Not Larger Single Server?
- **Cost:** Single 2-socket server costs more than 3 mini PCs
- **No redundancy:** One failure = downtime
- **Doesn't teach clustering:** Miss learning distributed systems
- **Overkill for most services:** Over-provisioned
- **Better for:** Single self-hosted services, if you're on very tight budget

### Why Not Cloud VPS?
- **No learning:** Miss hardware/infrastructure knowledge
- **Cost:** Expensive long-term ($100-300/month)
- **Privacy:** Cloud provider has access to everything
- **Vendor lock-in:** Can't migrate easily
- **Better for:** Production services, high-traffic apps, global distribution

### Why Not Kubernetes Immediately?
- **Complexity tax:** K8s adds learning curve
- **Overkill:** Docker Swarm or simpler orchestration sufficient for homelab
- **Still can graduate:** Once comfortable, migrate to K8s
- **Better approach:** Start simple, grow complexity as needed

## Next Steps

You now understand the hardware choices. Let's design the network infrastructure that ties it all together.

**Continue to:** [Session 1.4: Network Infrastructure and Design](./04-network-infrastructure.md)
