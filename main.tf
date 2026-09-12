terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

}


provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "first" {
  bucket = "viraj-session1-demo-bucket-2026"
}





data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "plant_advisor" {
  function_name = "smart-plant-watering-advisor"

  role    = data.aws_iam_role.lab_role.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}






resource "aws_secretsmanager_secret" "openweather_api_key" {
  name        = "smart-plant-openweather-api-key"
  description = "OpenWeather API key for Smart Plant Watering Advisor"
}





output "lab_role_arn" {
  value = data.aws_iam_role.lab_role.arn
}



resource "aws_dynamodb_table" "plant_history" {
  name         = "smart-plant-history"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "PlantID"

  attribute {
    name = "PlantID"
    type = "S"
  }
}



resource "aws_apigatewayv2_api" "plant_api" {
  name          = "smart-plant-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.plant_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.plant_advisor.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.plant_api.id
  route_key = "GET /weather"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.plant_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.plant_advisor.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.plant_api.execution_arn}/*/*"
}