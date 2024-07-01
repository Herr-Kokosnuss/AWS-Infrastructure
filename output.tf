# output of server name and id

output "Server_1_Name" {
  value = aws_instance.webser.tags["Name"]

}
output "Server_1_ID" {
  value = aws_instance.webser.id

}
output "Server_1_IP" {
  value = aws_instance.webser.public_ip

}