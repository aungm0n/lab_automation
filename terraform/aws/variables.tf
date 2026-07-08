variable "aws_region" {
  description = "AWS region to deploy resources into"
  default     = "ap-southeast-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.20.1.0/24"
}

variable "availability_zone" {
  description = "AZ for the public subnet"
  default     = "ap-southeast-2a"
}

variable "ssh_key_name" {
  description = "Name to register the SSH key pair under in AWS"
  default     = "lab-automation-key"
}

variable "public_key_path" {
  description = "Path to your local SSH public key file (e.g. ~/.ssh/id_ed25519.pub)"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into instances. Restrict this to your own IP, e.g. 1.2.3.4/32"
  type        = string
}

variable "instances" {
  description = "Map of EC2 instances to create, mirroring the shape of the libvirt vms variable"
  type = map(object({
    instance_type = string
  }))
  default = {
    web-01 = {
      instance_type = "t3.micro"
    }
  }
}

variable "ami_id" {
  description = "AMI ID to launch instances from (leave null to auto-select latest Debian 13 AMI)"
  type        = string
  default     = null
}
