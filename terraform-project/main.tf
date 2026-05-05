terraform {

 backend "s3" {

   bucket = "022950218142-terraform-tfstate"
   key    = "terraform/state"
   region = "eu-central-1"

   dynamodb_table = "terraform-tfstate-lock"

 }

}

module "users_table" {

 source = "./modules/dynamodb"

 table_name = "users"

}

module "tasks_table" {

 source = "./modules/dynamodb"

 table_name = "tasks"

}

data "aws_iam_role" "lambda_role" {
  name = "lambda-role"
}

resource "aws_lambda_function" "get_all_users" {
  function_name = "get_all_users"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/get_all_users.zip"
  role          = data.aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda/get_all_users.zip")
}

resource "aws_lambda_function" "get_all_tasks" {
  function_name = "get_all_tasks"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/get_all_tasks.zip"
  role          = data.aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda/get_all_tasks.zip")
}

resource "aws_lambda_function" "get_task" {
  function_name = "get_task"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/get_task.zip"
  role          = data.aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda/get_task.zip")
}

resource "aws_lambda_function" "save_task" {
  function_name = "save_task"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/save_task.zip"
  role          = data.aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda/save_task.zip")
}

resource "aws_lambda_function" "update_task" {
  function_name = "update_task"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/update_task.zip"
  role          = data.aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda/update_task.zip")
}

resource "aws_lambda_function" "delete_task" {
  function_name = "delete_task"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/delete_task.zip"
  role          = data.aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda/delete_task.zip")
}

########################################
########################################
########################################

resource "aws_s3_bucket" "frontend" {
  bucket = "tasks-frontend-app-123456"
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "s3:GetObject",
      Resource = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

resource "aws_s3_object" "frontend_files" {
  for_each = fileset("frontend/build", "**/*")

  bucket = aws_s3_bucket.frontend.id
  key    = each.value
  source = "frontend/build/${each.value}"
  etag   = filemd5("frontend/build/${each.value}")

  content_type = lookup(
    {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
      json = "application/json"
      png  = "image/png"
      jpg  = "image/jpeg"
      svg  = "image/svg+xml"
      ico  = "image/x-icon"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
}

########################################

resource "aws_cloudfront_distribution" "frontend" {

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "s3-frontend"
  }

  enabled = true

  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "s3-frontend"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  ########################################

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
}

########################################
########################################
########################################

resource "aws_iam_policy" "lambda_logs" {
  name = "lambda-logs-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role       = data.aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_policy" "cloudwatch_put_metric" {
  name = "cloudwatch-put-metric"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "cloudwatch:PutMetricData"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_metric" {
  role       = data.aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cloudwatch_put_metric.arn
}

############################

resource "aws_sns_topic" "alerts" {
  name = "app-alerts-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

############################

resource "aws_cloudwatch_metric_alarm" "lambda_errors_all" {
  alarm_name          = "lambda-errors-all-functions"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "custom_app_errors" {
  alarm_name          = "custom-app-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "AppErrors"
  namespace           = "MyApp/Metrics"
  period              = 60
  statistic           = "Sum"
  threshold           = 0

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}

############################

resource "aws_sns_topic" "billing_alerts" {
  provider = aws.billing
  name     = "billing-alerts-topic"
}

resource "aws_sns_topic_subscription" "billing_email" {
  provider  = aws.billing
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  provider = aws.billing

  alarm_name          = "monthly-billing-alarm"
  namespace           = "AWS/Billing"
  metric_name         = "EstimatedCharges"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0.001
  evaluation_periods  = 1
  period              = 21600
  statistic           = "Maximum"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [
    aws_sns_topic.billing_alerts.arn
  ]
}