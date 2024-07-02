# output of server name and id

output "Server_1_Name" {
  value = aws_instance.webser.tags["Name"]
  description = "The name of the server"
}
output "Server_1_ID" {
  value = aws_instance.webser.id
  description = "The ID of the server"
}
output "Server_1_IP" {
  value = aws_instance.webser.public_ip
  description = "The public IP of the server"
}

output "Server_2_IP" {
  value = aws_instance.webser.public_ip
  description = "The public IP of the server 2"
}