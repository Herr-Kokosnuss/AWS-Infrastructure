
# Creating ec2 instance.
resource "aws_instance" "webser" {
  ami           = "var.ami"
  instance_type = "t2.micro"
  tags = {
    Name = "webser"
  }
}

## Creating a security group for the instance
# resource "aws_security_group" "instance" {
#   name = "terraform-example-instance"
#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# Create an S3 bucket t
resource "aws_s3_bucket" "buck" {
  bucket = "test588558520025"
}

# Enable versioning on the bucket
resource "aws_s3_bucket_versioning" "buck_versioning" {
  bucket = aws_s3_bucket.buck.id

  versioning_configuration {
    status = "Enabled"
  }
}
# streamline the code by using dynamic blocks

locals {
  files = {
    "test.txt"  = "/home/frogy/AWS-linux/AWS/test.txt",
    "test1.txt" = "/home/frogy/AWS-linux/AWS/test1.txt",
    "frog.webp" = "/home/frogy/AWS-linux/AWS/frog.webp",
  }
}

resource "aws_s3_object" "kolama" {
  for_each = local.files

  bucket = aws_s3_bucket.buck.id
  key    = each.key
  source = each.value
}


# # creating an object in the bucket (uploading a single file to the bucket)

# resource "aws_s3_object" "koalacampaign" {
#   bucket = aws_s3_bucket.buck.bucket
#   key    = "test.txt"
#   source = "/home/frogy/aws-github/AWS/test.txt"
# }

# # creating a second object in the bucket with same bucket name

# resource "aws_s3_object" "koalacampaign2" {
#   bucket = aws_s3_bucket.buck.bucket
#   key    = "test1.txt"
#   source = "/home/frogy/aws-github/AWS/test1.txt"
# }


