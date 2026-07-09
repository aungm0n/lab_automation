# Infrastructure Automation Framework

An Infrastructure as Code framework that provisions and configures virtual machines on KVM/libvirt, using Packer for immutable image builds, Terraform for provisioning, and Ansible for baseline configuration and security hardening. Currently targets a home-lab KVM environment, with a modular design intended to extend to additional providers (AWS, VMware).

It is designed as a reproducible environment for experimenting with:
- Infrastructure as Code (IaC)
- Virtualization
- Configuration management
- Image-based VM workflows
- Multi-cloud / multi-provider provisioning

---

## Architecture Overview

```

                Debian ISO
                     │
                     ▼
                 Packer
                     │
                     ▼
         Golden qcow2 Image Template
                     │
                     ▼
                Terraform
             ┌───────┴────────┐
             ▼                ▼
   KVM/libvirt VMs        AWS EC2 Instances
   (local hypervisor)    (VPC + Subnet + SG)
             └───────┬────────┘
                     ▼                 
                 Ansible
                     │
                     ▼
     Packages • Security • SSH Hardening
     System Configuration • Kubernetes Prerequisites

```
Packer currently builds the golden image used for the KVM/libvirt path. The AWS path uses an official Debian AMI in place of a custom Packer image (a Packer-built AMI is a possible future addition — see [Future Improvements](#future-improvements)). Both paths converge at Ansible, since the roles are OS-level and provider-agnostic.

---

## Project Structure

```

.
├── packer/              # Packer templates for building base images (KVM/libvirt)
├── terraform/
│   ├── libvirt/         # Terraform configuration for KVM/libvirt VM provisioning
│   └── aws/             # Terraform configuration for AWS (VPC, EC2) provisioning
├── ansible/             # Ansible playbooks, inventories and roles
├── images/              # Built VM images (ignored in git)
├── iso/                 # OS installation ISO files (ignored in git)
├── keys/                # SSH keys (ignored in git)
├── Makefile             # Automation entry point
└── README.md

````

---

## Requirements

Before using this project, ensure the following are installed:

- KVM / QEMU
- libvirt
- virt-manager (optional GUI)
- Terraform >= 1.5
- Packer >= 1.9
- Ansible
- Make

For the AWS module, additionally:

- An AWS account
- AWS credentials available as environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- An SSH key pair to register with EC2 (path referenced via `public_key_path`)

---

## Setup

### 1. Clone repository

```bash
git clone https://github.com/aungm0n/lab_automation.git
cd lab_automation
````

---

### 2. Prepare ISO

Place your Debian ISO inside:

```text
iso/debian.iso
```
Note: I'm using debian 13 for testing.

---

### 3. Configure variables

Copy example variables for whichever provider(s) you're using:

```bash
# KVM/libvirt
cp terraform/libvirt/terraform.tfvars.example terraform/libvirt/terraform.tfvars
cp packer/variables.pkrvars.hcl.example packer/variables.pkrvars.hcl

# AWS
cp terraform/aws/terraform.tfvars.example terraform/aws/terraform.tfvars
```
For AWS, edit `terraform/aws/terraform.tfvars` and set `public_key_path` and `allowed_ssh_cidr` (your own public IP, not `0.0.0.0/0`) before applying.

---

## Usage Workflow

### KVM/libvirt path

**Step 1 — Build base image (Packer)**

```bash
make pk-init
make pk-validate
make pk-build
```

This creates a reusable **golden qcow2 image** inside:

```text
images/
```

---

**Step 2 — Initialize Terraform**

```bash
make tf-libvirt-init
```

---

**Step 3 — Deploy VMs**

```bash
make tf-libvirt-apply
```

This will create multiple VMs defined in `terraform.tfvars`.

---

**Step 4 — Ansible Provisioning**

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy_standard_vm.yml
```

Ansible performs post-provisioning configuration such as:

- Package installation
- System updates
- SSH hardening
- Auditd configuration
- Fail2ban installation
- Time synchronization
- Hostname configuration
- Kubernetes prerequisites (planned)

---

**Step 5 — Destroy the environment**

```bash
make tf-libvirt-destroy
```

---

### AWS path

**Step 1 — Initialize Terraform**

```bash
make tf-aws-init
```

---

**Step 2 — Deploy VMs**

```bash
make tf-aws-apply
```

This provisions a VPC, public subnet, security group, and EC2 instance(s) as defined in `terraform/aws/terraform.tfvars`, using the latest official Debian 13 AMI.

---

**Step 3 — Ansible Provisioning**

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy_standard_vm.yml
```

The same Ansible roles used for the libvirt path apply here unchanged, since they operate at the OS level rather than the hypervisor/cloud level.

**Step 4 — Destroy the environment**

```bash
make tf-aws-destroy
```

> **Note:** `terraform destroy` only affects resources tracked in that module's state. The `libvirt` and `aws` directories maintain separate state files, so destroying one has no effect on the other.

---

## Example VM Configuration

**KVM/libvirt** — defined in `terraform/libvirt/terraform.tfvars`:

```hcl
vms = {
  vm01 = {
    memory = 4096
    vcpu   = 2
  }

  vm02 = {
    memory = 4096
    vcpu   = 2
  }

  vm03 = {
    memory = 4096
    vcpu   = 2
  }
}
```

**AWS** — defined in `terraform/aws/terraform.tfvars`:

```hcl
aws_region       = "ap-southeast-2"
public_key_path  = "~/.ssh/id_rsa.pub"
allowed_ssh_cidr = "your_public_ip/32"

instances = {
  web-01 = {
    instance_type = "t3.micro"
  }
}
```

---

## Key Features

* Fully automated VM provisioning
* Packer-based immutable base image workflow
* Terraform-managed infrastructure across multiple providers (KVM/libvirt, AWS)
* qcow2 copy-on-write (COW) optimization for linked clones, with optional full clone support for independent VM disks
* Multi-VM scaling using `for_each`
* Provider-agnostic Ansible roles shared across libvirt and AWS
* Dynamic Ansible inventory sourced directly from Terraform output
* Repeatable homelab and cloud environments
* Repeatable homelab environment
* Image versioning (v1, v2, v3)
* SSH hardening
* Security baseline configuration

---

## Technology Stack

| Layer | Tool |
|--------|------|
| Image Creation | Packer |
| Infrastructure Provisioning | Terraform |
| Configuration Management | Ansible |
| Virtualization | KVM / libvirt |
| Cloud Provider | AWS (VPC, EC2) |
| Guest OS | Debian 13 |

---

## Notes

* This project is intended for **learning and homelab/cloud-sandbox use only**
* VM images, ISO files, and state files are excluded from version control
* Not production-hardened
* AWS resources incur real cost while running — always `terraform destroy` after testing

---

## Git Ignore

This project excludes:

* Terraform state files
* Packer output images
* ISO files
* SSH keys

See `.gitignore` for details.

---

## Future Improvements

* Cloud-init automation
* Packer-built AMI for AWS (matching the KVM/libvirt golden-image workflow)
* SSH inventory generation
* VMware provider support
* Kubernetes cluster bootstrap automation
* Remote Terraform state backend

---

## Author

Infrastructure automation project using open-source tooling:

* Packer
* Terraform
* Ansible
* KVM/QEMU
* libvirt
* AWS


