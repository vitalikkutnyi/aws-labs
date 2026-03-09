terraform {

 backend "s3" {

   bucket = "022950218142-terraform-tfstate"
   key    = "terraform/state"
   region = "eu-central-1"

   dynamodb_table = "terraform-tfstate-lock"

 }

}

module "authors_table" {

 source = "./modules/dynamodb"

 table_name = "authors"

}

module "courses_table" {

 source = "./modules/dynamodb"

 table_name = "courses"

}

data "aws_iam_role" "lambda_role" {
  name = "lambda-role"
}

resource "aws_lambda_function" "get_all_authors" {
  function_name = "get-all-authors"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/get-all-authors.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "get_all_courses" {
  function_name = "get-all-courses"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/get-all-courses.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "get_course" {
  function_name = "get-course"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/get-course.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "save_course" {
  function_name = "save-course"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/save-course.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "update_course" {
  function_name = "update-course"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/update-course.zip"
  role          = data.aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "delete_course" {
  function_name = "delete-course"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda/delete-course.zip"
  role          = data.aws_iam_role.lambda_role.arn
}