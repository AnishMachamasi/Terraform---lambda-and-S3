resource "aws_lambda_function" "my_function" {
  filename         = "./lambda_function.zip"
  function_name    = "extractFromPDF"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"  # Update with the appropriate runtime
  source_code_hash = filebase64sha256("./lambda_function.zip")
  timeout = 300
  # Attach the Lambda layer to the function
  layers = [aws_lambda_layer_version.my_layer.arn]
}

resource "aws_lambda_layer_version" "my_layer" {
  filename   = "./PyMuPDF-layer.zip"
  layer_name = "PyMuPDF"
  compatible_runtimes = ["python3.8"]  # Update with the runtime you are using
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

#attach inline policy to role
inline_policy {
  name = "AWSLambdaBasicExecutionRole"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
            {
                "Effect": "Allow",
                "Action": "logs:CreateLogGroup",
                "Resource": "arn:aws:logs:us-east-2:592588105397:*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": [
                    "arn:aws:logs:us-east-2:592588105397:log-group:/aws/lambda/extractFromPDF:*"
                ]
            }
        ]
  })
}

inline_policy {
  name = "AmazonS3FullAccess"
  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:*",
                    "s3-object-lambda:*"
                ],
                "Resource": "*"
            }
        ]
    }
  )
}

inline_policy {
  name = "AmazonS3ObjectLambdaExecutionRolePolicy"
  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "s3-object-lambda:WriteGetObjectResponse"
                ],
                "Resource": "*"
            }
        ]
    }
  )
}
}

