output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "ec2_web_public_ip" {
  description = "The public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "db_private_ip" {
  description = "The private IP address of the DB server"
  value       = aws_instance.db.private_ip
}
