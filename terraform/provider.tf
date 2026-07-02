terraform {
  required_version = ">= 1.5"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.2"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}