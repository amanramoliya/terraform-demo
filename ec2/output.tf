output "ec2-sg" {
  value = aws_security_group.instance_security_group.id
}

