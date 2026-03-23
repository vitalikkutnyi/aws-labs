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
}

resource "aws_lambda_function" "get_all_tasks" {
  function_name = "get_all_tasks"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/get_all_tasks.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "get_task" {
  function_name = "get_task"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/get_task.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "save_task" {
  function_name = "save_task"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/save_task.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "update_task" {
  function_name = "update_task"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/update_task.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "delete_task" {
  function_name = "delete_task"
  runtime       = "nodejs16.x"
  handler       = "index.handler"
  filename      = "lambda/delete_task.zip"
  role          = data.aws_iam_role.lambda_role.arn
}