
# Create an S3 bucket
resource "aws_s3_bucket" "buck" {
  bucket = "test58855852025"
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
    "test.txt"  = "/home/frogy/aws-github/AWS/test.txt",
    "test1.txt" = "/home/frogy/aws-github/AWS/test1.txt",
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


