output "lambda_function_name" {
  value = aws_lambda_function.execute_satellite_script.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.execute_satellite_script.arn
}

output "cloudwatch_event_rule_arn" {
  value = aws_cloudwatch_event_rule.trigger_every_minute.arn
}