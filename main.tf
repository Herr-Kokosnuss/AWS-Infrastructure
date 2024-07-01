
# Creating ec2 instance
resource "aws_instance" "test" {
  ami           = "ami-01b799c439fd5516a"
  instance_type = "t2.micro"

  tags = {
    Name = "test"
  }
}

# Creating another ec2 instance
resource "aws_instance" "test1" {
  ami           = "ami-01b799c439fd5516a"
  instance_type = "t2.micro"

  tags = {
    Name = "test1"
  }
}

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


