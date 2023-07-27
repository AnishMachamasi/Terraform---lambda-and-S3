resource "aws_s3_bucket" "SourceBucket" {
    bucket = "source-pdf-bucket"

    tags = {
      Name = "My bucket"
      Environment = "Dev"
    }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.SourceBucket.arn
}

#Add the S3 bucket event notification
resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = aws_s3_bucket.SourceBucket.id

    lambda_function {
        lambda_function_arn = aws_lambda_function.my_function.arn
        events              = ["s3:ObjectCreated:Put"]
    }
    depends_on = [aws_lambda_permission.allow_bucket]
}
