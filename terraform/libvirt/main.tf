resource "libvirt_volume" "base" {
  name   = "debian13-template"
  pool   = var.disk_pool
  source = var.base_image
  format = "qcow2"
}

resource "libvirt_volume" "disk" {
  for_each = var.vms

  name           = "${each.key}.qcow2"
  pool           = var.disk_pool
  #base_volume_id = libvirt_volume.base.id #for linked-clone
  source = var.base_image #for qcow full copy
  format = "qcow2" #for qcow full copy
}

resource "libvirt_domain" "vm" {
  for_each = var.vms

  name   = each.key
  memory = each.value.memory
  vcpu   = each.value.vcpu

  depends_on = [libvirt_volume.base]

  cpu {
    mode = "host-passthrough"
  }
  
  disk {
    volume_id = libvirt_volume.disk[each.key].id
  }

  network_interface {
    network_name = var.network
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
  }
}