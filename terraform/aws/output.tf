output "instance_public_ips" {
  value = {
    for k, v in aws_instance.vm : k => v.public_ip
  }
}

output "instance_ids" {
  value = {
    for k, v in aws_instance.vm : k => v.id
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}
