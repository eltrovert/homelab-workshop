# Session 2.1: Terraform and Infrastructure as Code

## Overview

In Session 1, you learned the theory of homelabs, hardware fundamentals, networking, and Proxmox architecture. Now in Session 2, you'll put that knowledge into practice by deploying infrastructure using **Infrastructure as Code (IaC)** principles with Terraform.

This hands-on session will guide you through:
- Understanding Terraform and why it matters for homelabs
- Installing and configuring Terraform
- Setting up the bpg/proxmox provider
- Creating your first infrastructure deployments
- Managing your infrastructure configuration as code

## What is Terraform?

Terraform is an open-source Infrastructure as Code (IaC) tool developed by HashiCorp. It allows you to define, deploy, and manage infrastructure using declarative configuration files rather than manual clicking through web interfaces.

### Key Concepts

**Declarative vs Imperative:**
- **Imperative:** "Do this, then do that" (traditional scripts)
- **Declarative:** "This is the desired state" (Terraform)

With Terraform, you describe what you want, not the steps to get there. Terraform figures out how to achieve that state.

**State Management:**
Terraform maintains a state file (terraform.tfstate) that tracks the current state of your infrastructure. This allows Terraform to know what exists and what needs to be created, modified, or destroyed.

## Why Terraform for Homelabs?

### Reproducibility
Deploy identical infrastructure every time. If something breaks, recreate it with `terraform apply`.

### Version Control
Store your infrastructure in Git. Review changes before applying them. Track who changed what and when.

### Collaboration
Share infrastructure code with others. Multiple team members can review and approve infrastructure changes.

### Documentation
Your Terraform files serve as living documentation of your infrastructure. Anyone can read the code and understand what services are running.

### Speed
Deploy entire infrastructure stacks in minutes instead of hours of manual configuration.

### Disaster Recovery
If your homelab fails, you can rebuild it from your Terraform configuration and state file.

### Consistency
Eliminate human error from manual deployments. The same configuration always produces the same results.

## Installing Terraform

### Download and Install

**Linux:**
```bash
# Set Terraform version (check latest at https://www.terraform.io/downloads)
TERRAFORM_VERSION="1.7.0"

# Download
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Extract
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Move to PATH
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

**macOS (using Homebrew):**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify
terraform version
```

**Windows (using Chocolatey):**
```powershell
choco install terraform

# Verify
terraform version
```

### Verify Installation

```bash
$ terraform version
Terraform v1.7.0
on linux_amd64
```

## The bpg/proxmox Provider

Terraform uses **providers** to interact with APIs. For Proxmox, we use the **bpg/proxmox** provider (formerly telmate/proxmox, now maintained by bpg).

### Why bpg/proxmox?

- **Active Maintenance:** Regular updates and bug fixes
- **Feature Complete:** Covers all major Proxmox resources (VMs, containers, networks, firewalls)
- **Better Documentation:** Clear examples and parameter documentation
- **Community Driven:** Large user base, active issue resolution
- **Performance:** Optimized for speed and reliability

### Provider Versions

Version ~> 0.71 (used in this workshop) includes:
- LXC container management
- VM management with cloud-init support
- Multiple disk support
- Network configuration
- Firewall rules
- User and permission management

## Creating a Proxmox API Token

Terraform needs credentials to access your Proxmox cluster. Instead of using password authentication, we'll create an API token (more secure, easier to revoke).

### Method 1: Using the Proxmox Web UI

1. **Access the Proxmox Web Console**
   ```
   https://192.168.10.129:8006
   ```
   Log in with your Proxmox credentials (usually root).

2. **Navigate to API Tokens**
   - Click **Datacenter** (left sidebar)
   - Click **Permissions** > **API Tokens**

3. **Create New Token**
   - Click **Add**
   - User: `root@pam`
   - Token ID: `terraform`
   - Privilege Separation: (leave unchecked for now)
   - Click **Add**

4. **Copy and Save the Token**
   You'll see a dialog with the full token value:
   ```
   root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```

   Save this securely. You'll only see it once.

5. **Grant Permissions** (important!)
   - Still on the **Permissions** > **API Tokens** page
   - Select the token you just created
   - Click **Edit**
   - Grant these permissions at the **Datacenter** level:
     - `Sys.Audit`
     - `Sys.Console`
     - `Sys.Modify`
     - `VMs.Allocate`
     - `VMs.Clone`
     - `VMs.ConfigureCloudInit`
     - `VMs.Console`
     - `VMs.Create`
     - `VMs.Delete`
     - `VMs.Migrate`
     - `VMs.Monitor`
     - `VMs.PowerMgmt`

### Method 2: Using pveum (Command Line)

SSH into a Proxmox node and run:

```bash
# Create the API token
pveum user token add root@pam terraform --privsep 0

# Grant permissions
pveum aclmod / -user root@pam -token terraform -role Administrator
```

The output will show your token value. Save it securely.

### Token Format

Your API token has two parts:
```
root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ^         ^          ^
   user      ID         secret
```

Store securely:
- `proxmox_api_token_id`: `root@pam!terraform`
- `proxmox_api_token_secret`: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

## Terraform Configuration Files

### File Structure

Create a new directory for your Terraform code:

```bash
mkdir -p ~/homelab/proxmox-terraform
cd ~/homelab/proxmox-terraform
```

Your directory structure will look like:

```
proxmox-terraform/
├── providers.tf        # Provider configuration
├── variables.tf        # Variable definitions
├── terraform.tfvars    # Variable values (secrets!)
├── main.tf             # Main infrastructure code
├── outputs.tf          # Output values
├── modules/
│   ├── lxc/           # LXC container module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── vm/            # VM module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── terraform.tfstate   # State file (auto-generated)
```

### providers.tf

This file defines which providers Terraform uses and their configuration.

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.71"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  insecure = var.proxmox_tls_insecure
  api_token = var.proxmox_api_token_secret != "" ? "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" : null
}
```

**What it does:**
- `required_version`: Ensures Terraform is version 1.0 or later
- `required_providers`: Specifies the bpg/proxmox provider ~> 0.71 (any 0.7x version)
- `provider "proxmox"`: Configures the Proxmox connection
  - `endpoint`: The Proxmox API URL (HTTPS)
  - `insecure`: Whether to skip TLS verification (true for self-signed certs)
  - `api_token`: Combines token ID and secret

### variables.tf

This file defines all input variables for your Terraform configuration.

```hcl
# Proxmox API Configuration
variable "proxmox_api_url" {
  description = "URL of the Proxmox API"
  type        = string
  default     = "https://192.168.10.129:8006/api2/json"
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification (useful for self-signed certificates)"
  type        = bool
  default     = true
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID (e.g., root@pam!terraform)"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

# Cluster Configuration
variable "proxmox_cluster_node" {
  description = "Target Proxmox cluster node (prx01, prx02, or prx03)"
  type        = string
  default     = "prx01"
}

# General Variables
variable "timezone" {
  description = "Timezone for containers and VMs"
  type        = string
  default     = "UTC"
}

variable "management_vlan" {
  description = "Management network CIDR"
  type        = string
  default     = "192.168.10.0/24"
}

variable "gateway" {
  description = "Default gateway IP address"
  type        = string
  default     = "192.168.10.1"
}
```

**Key points:**
- `sensitive = true` for credentials prevents them from being printed in logs
- Variables can have default values or be required
- `description` documents what each variable does
- `type` enforces the variable type (string, number, bool, list, map, etc.)

### terraform.tfvars

This file sets the actual values for variables. **Never commit this to Git** (contains secrets).

```hcl
# Proxmox Credentials
proxmox_api_token_id     = "root@pam!terraform"
proxmox_api_token_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Proxmox API
proxmox_api_url      = "https://192.168.10.129:8006/api2/json"
proxmox_tls_insecure = true
proxmox_cluster_node = "prx01"

# Networking
timezone       = "UTC"
management_vlan = "192.168.10.0/24"
gateway        = "192.168.10.1"
```

### terraform.tfvars.example

This template shows what variables need to be set. **Do commit this to Git** (no secrets).

```hcl
# Proxmox Credentials
# Get your token from Proxmox > Datacenter > Permissions > API Tokens
proxmox_api_token_id     = "root@pam!terraform"
proxmox_api_token_secret = "YOUR-TOKEN-SECRET-HERE"

# Proxmox API
# Replace with your Proxmox primary node IP
proxmox_api_url      = "https://192.168.10.129:8006/api2/json"
proxmox_tls_insecure = true
proxmox_cluster_node = "prx01"

# Networking
timezone        = "UTC"
management_vlan = "192.168.10.0/24"
gateway         = "192.168.10.1"
```

### .gitignore

Protect secrets from being committed to Git:

```
# Terraform state files
*.tfstate
*.tfstate.*
.terraform.lock.hcl

# Terraform cache
.terraform/

# Environment files with secrets
terraform.tfvars
.env
.envrc

# IDE
.idea/
*.swp
*.swo
*~
.vscode/
```

## Terraform Workflow

### Step 1: Initialize Terraform

```bash
terraform init
```

This downloads the provider and initializes the working directory.

**Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding bpg/proxmox versions matching "~> 0.71"...
- Installing bpg/proxmox v0.71.0...
- Installed bpg/proxmox v0.71.0

Terraform has been successfully initialized!
```

### Step 2: Review Your Configuration

```bash
terraform validate
```

Checks that your configuration is valid. Doesn't check if values exist in Proxmox yet.

**Output:**
```
Success! The configuration is valid.
```

### Step 3: Plan the Changes

```bash
terraform plan
```

Shows what Terraform will do without making changes. Always review this before applying.

**Output:**
```
Terraform will perform the following actions:

  # proxmox_lxc_container.docker_host will be created
  + resource "proxmox_lxc_container" "docker_host" {
      + hostname      = "docker-host"
      + vmid          = 100
      + target_node   = "prx01"
      + cores         = 4
      + memory        = 8192
      # ... more attributes ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

### Step 4: Apply the Changes

```bash
terraform apply
```

Applies the changes to your infrastructure. You'll see the plan again and must confirm:

```
Do you want to perform these actions?
  Terraform will perform the following actions:
  # ... changes shown ...

  Enter a value: yes
```

After confirmation:

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## State Management

Terraform stores information about your infrastructure in a **state file** (terraform.tfstate).

### Important: Protect Your State File

The state file contains sensitive information (passwords, API tokens, etc.). Protect it:

```bash
# Never commit state files to Git
git add .gitignore  # Ensure .gitignore includes *.tfstate
git add terraform.tfvars.example  # Example only, no secrets
git status  # Verify state files are ignored
```

### Viewing State

```bash
# See all resources in state
terraform state list

# See details of a specific resource
terraform state show proxmox_lxc_container.docker_host
```

### Making Changes

When you modify your Terraform code:

1. **Update your .tf files**
2. **Review the plan:** `terraform plan`
3. **Apply changes:** `terraform apply`

Terraform will calculate the diff and only change what's needed.

### Destroying Infrastructure

```bash
terraform destroy
```

Removes all resources managed by Terraform. Use with caution!

**Output:**
```
Terraform will perform the following actions:

  # proxmox_lxc_container.docker_host will be destroyed

Plan: 0 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Enter a value: yes
```

## Best Practices

### 1. Always Plan Before Applying
```bash
terraform plan -out=tfplan
# Review the plan
terraform apply tfplan
```

### 2. Use Variables for Configuration
Don't hardcode values. Use variables for:
- IPs and network settings
- Resource names
- Sizing (cores, memory, disk)
- Credentials

### 3. Document Your Code
```hcl
# Clear descriptions help others understand your infrastructure
variable "docker_host_cores" {
  description = "Number of CPU cores for the Docker host LXC container"
  type        = number
  default     = 4
}
```

### 4. Use Meaningful Names
```hcl
# Good
resource "proxmox_lxc_container" "docker_host" { ... }
resource "proxmox_lxc_container" "app_server_01" { ... }

# Bad
resource "proxmox_lxc_container" "lxc1" { ... }
resource "proxmox_lxc_container" "test" { ... }
```

### 5. Separate Concerns with Modules
As your infrastructure grows, use modules to organize code:
- `modules/lxc/` for container logic
- `modules/vm/` for virtual machine logic
- `modules/networking/` for network configuration

### 6. Version Your Infrastructure Code
Use Git to track changes:
```bash
git add .
git commit -m "Add Docker host LXC container with 4 cores and 8GB RAM"
```

### 7. Keep Secrets Out of Git
Never commit terraform.tfvars:
```bash
# Create from example
cp terraform.tfvars.example terraform.tfvars

# Populate with real values
nano terraform.tfvars

# Verify it's ignored
git status
```

## Troubleshooting

### Authentication Error
```
Error: failed to authenticate: Invalid API token
```

**Solution:**
- Verify `proxmox_api_token_id` and `proxmox_api_token_secret` are correct
- Check that the token exists in Proxmox and hasn't been revoked
- Ensure the token has proper permissions

### TLS Certificate Error
```
Error: failed to retrieve authentication ticket: x509: certificate signed by unknown authority
```

**Solution:**
- Set `proxmox_tls_insecure = true` in variables.tf (Proxmox uses self-signed certs)
- Or install the self-signed certificate in your system's trust store

### Resource Already Exists
```
Error: resource with VMID 100 already exists
```

**Solution:**
- Check if the resource exists in Proxmox
- Either delete it in the UI or import it with `terraform import`
- Change the VMID to an unused number

## Next Steps

You now understand Terraform and Infrastructure as Code concepts. In the next section, you'll:
- Create Terraform modules for LXC containers and VMs
- Deploy your first infrastructure using Terraform
- Use Terraform to manage your Proxmox cluster

Let's move on to deploying your Docker host!
