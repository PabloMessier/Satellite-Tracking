provider "aws" {
  region = "us-east-1" # Specify your AWS region
}

resource "aws_lambda_function" "execute_satellite_script" {
  function_name = "execute_satellite_script"
  filename      = "satellite.zip"     // Make sure this is the name of your ZIP file
  handler       = "satellite.handler" // Adjust if your function is named differently
  runtime       = "python3.12"        // Use the appropriate Python runtime version
  role          = aws_iam_role.lambda_iam_role.arn
  timeout       = 120

  environment {
    variables = {
      COLORAMA_ENABLED = "true" # Example environment variable
    }
  }
}

resource "aws_kinesis_stream" "satellite_logs_stream" {
  name             = "satellite-logs-stream"
  retention_period = 24

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = "development"
  }
}

resource "aws_cloudwatch_log_group" "satellite_log_group" {
  name              = "/aws/lambda/execute_satellite_script"
  retention_in_days = 0 # Set this according to your preference, 0 for never expire
}

resource "aws_cloudwatch_log_subscription_filter" "satellite_log_filter" {
  name            = "satellite-log-filter"
  log_group_name  = aws_cloudwatch_log_group.satellite_log_group.name
  filter_pattern  = "" # Use appropriate filter pattern
  destination_arn = aws_kinesis_stream.satellite_logs_stream.arn
  role_arn        = aws_iam_role.cloudwatch_kinesis_role.arn
}