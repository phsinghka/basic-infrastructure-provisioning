output "web_public_ip" {
  description = "The Public IP for WebInstance"
  value       = aws_instance.web.public_ip
}

output "vpc_id" {
  description = "The VPC id"
  value       = aws_vpc.main.id
}
