resource "aws_lambda_function" "buildfunction" {
  filename      = "deployment.zip"
  function_name = "${var.lambda_function}"
  role          = "${aws_iam_role.lambda_role.arn}"
  memory-size   = 1024
  handler       = "main"
  runtime       = "java8"
}
