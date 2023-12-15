terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    } 

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "auto-tagging-tf" {
  name               = "auto-tagging-tf"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "code.py"
  output_path = "code.zip"
}


resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "code.zip"
  function_name = "auto-tagging-tf"
  role          = aws_iam_role.auto-tagging-tf.arn
  handler       = "code.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime = "python3.9"
  timeout = 10
}

resource "aws_cloudwatch_event_rule" "console" {
  name        = "auto-tagging-tf"
  description = "Invoke lambda when new ec2 or lambdas are created, so that they can be autotagged"

  event_pattern = jsonencode({
    detail = {
        configurationItem = {
            configurationItemStatus = ["ResourceDiscovered"],
            resourceType = ["AWS::Lambda::Function", "AWS::EC2::Instance"]
        },
        messageType = ["ConfigurationItemChangeNotification"]
    },
    detail-type = ["Config Configuration Item Change"],
    source = ["aws.config"]
  })
}


resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.test_lambda.arn
}
