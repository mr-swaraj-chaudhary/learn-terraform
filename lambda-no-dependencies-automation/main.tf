provider "aws" {
    region = "us-west-2"
    shared_credentials_files = [ "/Users/sk255251/.aws/credentials" ]
}

resource "aws_iam_role" "lambda_role" {
 name   = "terraform_aws_lambda_role"
 assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]})
}

resource "aws_iam_policy" "lambda_policy" {
  name         = "terraform_aws_lambda_policy"
  path         = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow"
        }
    ]})
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
    role        = aws_iam_role.lambda_role.name
    policy_arn  = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "${path.module}/code/"
    output_path = "${path.module}/deployment-package.zip"
}

resource "aws_lambda_function" "lambda" {
    filename                       = data.archive_file.lambda_zip.output_path
    function_name                  = "lambda-no-dependencies-automation"
    role                           = aws_iam_role.lambda_role.arn
    handler                        = "lambda.lambda_handler"
    runtime                        = "python3.11"
    depends_on                     = [ aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role ]
}