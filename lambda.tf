data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

data "archive_file" "lambda_layer_zip" {
  type       = "zip"
  source_dir = "${path.module}/layer/python"
  output_path = "${path.module}/layer.zip"
}

resource "aws_lambda_layer_version" "compliance_layer" {
  filename           = data.archive_file.lambda_layer_zip.output_path
  layer_name         = "compliance_checker_layer"
  compatible_runtimes = ["python3.9"]
  source_code_hash   = data.archive_file.lambda_layer_zip.output_base64sha256
}

resource "aws_lambda_function" "compliance_checker" {
  function_name = "compliance_checker_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      REPORT_BUCKET = aws_s3_bucket.compliance_reports.bucket
    }
  }

  layers = [
    aws_lambda_layer_version.compliance_layer.arn
  ]
}