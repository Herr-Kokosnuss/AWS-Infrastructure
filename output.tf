# output of server name and id

output "Server1_name" {
  value = aws_instance.test.tags["Name"]
  
}
output "Server1_ID" {
  value = aws_instance.test.id
  
}

output "Server2_name" {
  value = aws_instance.test1.tags["Name"]
  
}

output "Server2_ID" {
  value = aws_instance.test1.id
  
}