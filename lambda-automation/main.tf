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

data "archive_file" "zip_the_python_code" {
    type        = "zip"
    source_dir  = "${path.module}/python/"
    output_path = "${path.module}/python/lambda-automation-test-swaraj.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
    filename                       = "${path.module}/python/lambda-automation-test-swaraj.zip"
    function_name                  = "Lambda-Automation-Test-Function"
    role                           = aws_iam_role.lambda_role.arn
    handler                        = "lambda-automation-test-swaraj.lambda_handler"
    runtime                        = "python3.11"
    depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}


output "teraform_aws_role_output" {
    value = aws_iam_role.lambda_role.name
}

output "teraform_aws_role_arn_output" {
    value = aws_iam_role.lambda_role.arn
}

output "teraform_logging_arn_output" {
    value = aws_iam_policy.lambda_policy.arn
}