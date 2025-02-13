output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = aws_instance.bastion.public_ip
}

output "private_server_private_ip" {
  description = "Private IP of private server"
  value       = aws_instance.private_server.private_ip
}

output "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  value       = aws_security_group.bastion_sg.id
}

output "private_security_group_id" {
  description = "Security group ID for private server"
  value       = aws_security_group.private_sg.id
}
