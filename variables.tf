variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "ap-southeast-2"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "lambda"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store Lambda code"
  type        = string
  default     = "simo-test-bucket-57334"
}


variable "api_name" {
  description = "The name of the api"
  type        = string
  default     = "video-api"
}


variable "dynamodb_table_name" {
  description = "The name of the existing DynamoDB table"
  type        = string
  default     = "family-video"
}
