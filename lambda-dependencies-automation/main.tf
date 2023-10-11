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

resource "null_resource" "pip_install" {
    triggers = {
        shell_hash = sha256(file("${path.module}/requirements.txt"))
    }
  
    provisioner "local-exec" {
        command = "python3 -m pip install -r requirements.txt -t ${path.module}/dependencies"
    }
}

resource "null_resource" "deployment_package" {
    triggers = {
        always_run = "${timestamp()}"
    }

    provisioner "local-exec" {
        command = "cd dependencies && zip -r ../deployment-package.zip . && cd .. && cd code && zip -g ../deployment-package.zip lambda.py"
    }
    
    depends_on = [ null_resource.pip_install ]
}

resource "aws_lambda_function" "lambda" {
    function_name                  = "lambda-dependencies-automation"
    handler                        = "lambda.lambda_handler"
    runtime                        = "python3.11"
    filename                       = "deployment-package.zip"
    role                           = aws_iam_role.lambda_role.arn
    depends_on                     = [ aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role, null_resource.pip_install, null_resource.deployment_package ]
}