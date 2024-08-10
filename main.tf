provider "aws" {
  region = var.aws_region
}

data "aws_lambda_function" "presign_lambda" {
  function_name = var.lambda_function_name 
}


data "aws_dynamodb_table" "dynamodb_table" {
  name = var.dynamodb_table_name
}


resource "aws_iam_role" "appsync_role" {
  name = "appsync-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "appsync_role_policy" {
  role = aws_iam_role.appsync_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ],
        Effect   = "Allow",
        Resource = data.aws_lambda_function.presign_lambda.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "appsync_logging_policy" {
  role = aws_iam_role.appsync_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}




resource "aws_iam_policy" "appsync_dynamoDb_policy" {
  name = "appsync-example-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Effect   = "Allow"
        Resource = data.aws_dynamodb_table.dynamodb_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "appsync_policy_attachment" {
  role       = aws_iam_role.appsync_role.name
  policy_arn = aws_iam_policy.appsync_dynamoDb_policy.arn
}


resource "aws_appsync_graphql_api" "api" {
  name                = var.api_name
  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.appsync_role.arn
    field_log_level          = "ALL"
  }
  authentication_type = "API_KEY"
  schema              = file("${path.module}/api/schema/schema.graphql")

  }

resource "aws_appsync_api_key" "api_key" {
  api_id = aws_appsync_graphql_api.api.id
}



resource "aws_appsync_datasource" "lambda_datasource" {
  api_id           = aws_appsync_graphql_api.api.id
  name             = "LambdaDatasource"
  type             = "AWS_LAMBDA"
  lambda_config {
    function_arn = data.aws_lambda_function.presign_lambda.arn
  }
  service_role_arn = aws_iam_role.appsync_role.arn
}


resource "aws_appsync_datasource" "dyanmodb_datasource" {
  api_id           = aws_appsync_graphql_api.api.id
  name             = "DynamoDatasource"
  type             = "AMAZON_DYNAMODB"
  service_role_arn = aws_iam_role.appsync_role.arn

  dynamodb_config {
    table_name        = data.aws_dynamodb_table.dynamodb_table.name
    use_caller_credentials = false
  }
}


resource "aws_lambda_permission" "appsync_lambda" {
  statement_id  = "AllowAppSyncInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.presign_lambda.function_name
  principal     = "appsync.amazonaws.com"
}

resource "aws_appsync_resolver" "get_presigned_url" {
  api_id          = aws_appsync_graphql_api.api.id
  type            = "Query"
  field           = "getPresignedUrl"
  data_source     = aws_appsync_datasource.lambda_datasource.name
  request_template = file("${path.module}/api/resolvers/request-url.vtl")
  response_template =file("${path.module}/api/resolvers/response-url.vtl")
}


resource "aws_appsync_resolver" "add_form_item" {
  api_id          = aws_appsync_graphql_api.api.id
  type            = "Mutation"
  field           = "putFormItem"
  data_source     = aws_appsync_datasource.lambda_datasource.name
  request_template = file("${path.module}/api/resolvers/request-put-form-item.vtl")
  response_template =file("${path.module}/api/resolvers/response-put-form-item.vtl")
}
