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
  function_name = "get-all-users"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/get-all-users.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "get_all_tasks" {
  function_name = "get-all-tasks"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/get-all-tasks.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "get_task" {
  function_name = "get-task"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/get-task.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "save_task" {
  function_name = "save-task"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/save-task.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "update_task" {
  function_name = "update-task"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/update-task.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "delete_task" {
  function_name = "delete-task"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/delete-task.zip"
  role          = data.aws_iam_role.lambda_role.arn
}