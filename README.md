# Homelab Infrastructure Automation (Packer + Terraform + Ansible + KVM/libvirt)

This project automates the creation of virtual machines on a local KVM/libvirt hypervisor using **Packer**, **Terraform** and **Ansible**..

It is designed as a reproducible homelab environment for experimenting with:
- Infrastructure as Code (IaC)
- Virtualization
- Configuration management
- Kubernetes cluster provisioning
- Image-based VM workflows

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
                     │
                     ▼
         KVM/libvirt Virtual Machines
                     │
                     ▼
                 Ansible
                     │
                     ▼
     Packages • Security • SSH Hardening
     System Configuration • Kubernetes Prerequisites

```

---

## Project Structure

```

.
├── packer/              # Packer templates for building base images
├── terraform/           # Terraform configuration for VM provisioning
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

### 3. (Optional) Configure variables

Copy example variables:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
cp packer/variables.pkrvars.hcl.example packer/variables.pkrvars.hcl
```

---

## Usage Workflow

### Step 1 — Build base image (Packer)

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

### Step 2 — Initialize Terraform

```bash
make tf-init
```

---

### Step 3 — Deploy VMs

```bash
make tf-apply
```

This will create multiple VMs defined in `terraform.tfvars`.

---

### Step 4 — Destroy environment

```bash
ansible-playbook -i ansible/inventory.ini ansible/site.yml
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

### Step 5 — Destroy the environment

```bash
make tf-destroy
```

---

## Example VM Configuration

Defined in `terraform/terraform.tfvars`:

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

---

## Key Features

* Fully automated VM provisioning
* Packer-based immutable base image workflow
* Terraform-managed infrastructure
* qcow2 copy-on-write (COW) optimization for linked clones, with optional full clone support for independent VM disks
* Multi-VM scaling using `for_each`
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
| Guest OS | Debian 13 |

---

## Notes

* This project is intended for **learning and homelab use only**
* VM images, ISO files, and state files are excluded from version control
* Not production-hardened

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
* SSH inventory generation
* Ansible integration
* Kubernetes cluster bootstrap automation
* Remote Terraform state backend

---

## Author

Homelab infrastructure automation project using open-source tooling:

* Packer
* Terraform
* KVM/QEMU
* libvirt


