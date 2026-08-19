resource "aws_cloudwatch_event_rule" "daily_schedule" {
  name                = "daily_compliance_check"
  description         = "Trigger for compliance checker Lambda"
  schedule_expression = "cron(0 0 * * ? *)"  # Every day at midnight UTC
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_schedule.name
  target_id = "compliance_checker_lambda"
  arn       = aws_lambda_function.compliance_checker.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.compliance_checker.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_schedule.arn
}