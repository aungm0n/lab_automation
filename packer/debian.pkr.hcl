packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "image_name" {
    type = string
}
variable "image_version" {
    type = string
}
variable "cpus" {
    type = number
}
variable "memory" {
    type = number
}
variable "disk_size" {
    type = string
}
variable "iso_path" {
    type = string
}
variable "iso_checksum" {
    type = string
}
variable "ssh_username" {
    type = string
}
variable "ssh_password" {
    type = string
    sensitive = true
}
variable "output_dir" {
    type = string
}
variable "locale" {
    type = string
}
variable "keyboard" {
    type = string
}
variable "timezone" {
    type = string
}

source "qemu" "debian13" {

  vm_name        = "${var.image_name}-${var.image_version}"
  output_directory = "${var.output_dir}/${var.image_name}-${var.image_version}"

  accelerator = "kvm"
  format      = "qcow2"

  # Debian 13 ISO
  iso_url = var.iso_path
  iso_checksum = var.iso_checksum

  #disk_image = true

  disk_size = var.disk_size

  cpus   = var.cpus
  memory = var.memory

  headless = true

  boot_wait = "5s"

  http_directory = "http"

  # Boot into automated Debian installer (preseed)
  boot_command = [
    "<esc><wait>",
    "auto ",
    "priority=critical ",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "<enter>"
  ]

  shutdown_command = "echo '${var.ssh_password}' | sudo -S poweroff"
  communicator = "ssh"

  ssh_username         = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout          = "30m"
  
  qemuargs = [

    ["-machine", "type=q35,accel=kvm"],

    ["-cpu", "host"],

    ["-smp", "${var.cpus}"],

    ["-m", "${var.memory}"],

    ["-serial", "stdio"],

    ["-display", "none"],

    ["-boot", "order=cd"]

  ]
}

build {

  sources = ["source.qemu.debian13"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S sh '{{ .Path }}'"

    inline = [

      "apt update",

      "apt install -y qemu-guest-agent systemd-resolved",

      "systemctl enable qemu-guest-agent",

      "apt autoremove -y",

      "apt clean",

      "rm -f /etc/sudoers.d/labuser",

      "truncate -s 0 /etc/machine-id",

      "rm -f /var/lib/dbus/machine-id",

      "rm -f /etc/ssh/ssh_host_*",

      "ssh-keygen -A",

      "sync"

    ]
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S sh '{{ .Path }}'"

    script = "provisioners/systemd-networkd.sh"
  }
}