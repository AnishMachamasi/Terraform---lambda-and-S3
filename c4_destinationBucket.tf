resource "aws_s3_bucket" "DestinationBucket" {
    bucket = "destination-pdf-bucket"

    tags = {
      Name = "My bucket 2"
      Environment = "Dev"
    }
}
