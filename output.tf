# output of server name and id

output "Server_1_Name" {
  value = aws_instance.test.tags["Name"]

}
output "Server_1_ID" {
  value = aws_instance.test.id

}
output "Server_1_IP" {
  value = aws_instance.test1.public_ip

}
output "Server_2_Name" {
  value = aws_instance.test1.tags["Name"]

}
output "Server_2_ID" {
  value = aws_instance.test1.id
}
output "Server_2_IP" {
  value = aws_instance.test1.public_ip

}