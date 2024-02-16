resource "aws_cloudwatch_event_rule" "trigger_every_minute" {
  name                = "trigger_every_minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.trigger_every_minute.name
  target_id = "InvokeLambdaTarget"
  arn       = aws_lambda_function.execute_satellite_script.arn
}

resource "aws_lambda_permission" "allow_eventbridge_to_invoke_lambda" {
  statement_id  = "AllowEventBridgeToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.execute_satellite_script.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_every_minute.arn
}