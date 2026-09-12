# Smart Plant Watering Advisor

## Project Overview

This project is a serverless cloud application built using AWS and Terraform.

The application receives a city name through API Gateway, invokes an AWS Lambda function, retrieves live weather information from the OpenWeather API, and recommends whether the plant should be watered. The Lambda function also stores the weather information in DynamoDB and writes logs to CloudWatch.

## AWS Services Used

- AWS Lambda
- API Gateway
- DynamoDB
- Secrets Manager
- CloudWatch
- Terraform

## Files Included

- main.tf - Terraform infrastructure code
- lambda_function.py - Lambda application source code
- lambda_function.zip - Deployment package for Lambda
- response.json - Example API response

## Deployment

Initialize Terraform:

terraform init

Deploy the infrastructure:

terraform apply

Remove the infrastructure:

terraform destroy