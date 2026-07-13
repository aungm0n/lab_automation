variable "vms" {
  type = map(object({
    memory = number
    vcpu = number
  }))
}

variable "disk_pool" {
  default = "pool"
}

variable "network" {
  default = "default"
}

variable "base_image" {
  default = "/images/debian13-template-v1/debian13-template-v1"
}