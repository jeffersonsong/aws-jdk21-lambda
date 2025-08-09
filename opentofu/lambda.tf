# IAM Roles and Policies
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

data "aws_iam_policy" "basic_lambda_exec" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "logging" {
  name   = "logging"
  policy = data.aws_iam_policy.basic_lambda_exec.policy
}

resource "aws_iam_role_policy_attachment" "logging" {
  policy_arn = aws_iam_policy.logging.arn
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_s3_object" "lambda_jar" {
  bucket = aws_s3_bucket.bucket.id
  key    = var.lambda_filename
  source = var.file_location
  etag   = filesha256(var.file_location)
}

resource "aws_lambda_function" "test_lambda" {
  function_name = var.lambda_function
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.lambda_handler

  s3_bucket         = aws_s3_bucket.bucket.id
  s3_key            = aws_s3_object.lambda_jar.key
  s3_object_version = aws_s3_object.lambda_jar.version_id

  runtime = "java21"
  environment {
    variables = {
      FUNCTION_NAME = "obfuscate"
    }
  }

  lifecycle {
    replace_triggered_by = [
      aws_s3_object.lambda_jar.version_id
    ]
  }
}

resource "aws_lambda_permission" "sqs" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "sqs.amazonaws.com"
}
