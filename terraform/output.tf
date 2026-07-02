output "vm_name" {
  value = {
    for k, v in libvirt_domain.vm : k => v.name
  }
}