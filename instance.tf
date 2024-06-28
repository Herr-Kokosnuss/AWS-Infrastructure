# creat ec2 instance
resource "aws_instance" "test" {
  ami           = "ami-01b799c439fd5516a"
  instance_type = "t2.micro"
}