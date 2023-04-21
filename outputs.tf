output "IP" {
  value = aws_instance.master.public_ip
}
output "IP worker" {
  value = aws_instance.slave.public_ip
}
