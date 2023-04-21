output "IP" {
  value = aws_instance.master.public_ip
}
output "IP-slave" {
  value = aws_instance.slave.public_ip
}
