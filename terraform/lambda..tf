# ----------------------------------------
# Lambda Layer com psycopg2
# ----------------------------------------
resource "aws_lambda_layer_version" "psycopg2_layer" {
  layer_name          = "psycopg2-py310"
  compatible_runtimes = ["python3.10"]

  filename         = "${path.module}/../layers/psycopg2-layer.zip"
  source_code_hash = filebase64sha256("${path.module}/../layers/psycopg2-layer.zip")
}

# ----------------------------------------
# Lambda: Coleta via API
# ----------------------------------------
resource "aws_lambda_function" "bix_api_collector" {
  function_name = "bix_api_collector"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.10"

  filename         = "${path.module}/../lambda/build/lambda_package_api.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/build/lambda_package_api.zip")

  timeout = 60
}

# ----------------------------------------
# Lambda: Coleta via banco de dados
# ----------------------------------------
resource "aws_lambda_function" "bix_db_collector" {
  function_name = "bix_db_collector"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.10"

  filename         = "${path.module}/../lambda/build/lambda_package_db.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/build/lambda_package_db.zip")

  timeout = 60

  layers = [
    aws_lambda_layer_version.psycopg2_layer.arn
  ]

  environment {
    variables = {
      DB_HOST = "ep-frosty-sun-a591wc97.us-east-2.aws.neon.tech"
      DB_PORT = "5432"
      DB_NAME = "juniordatabase"
      DB_USER = "junior"
      DB_PASS = "npg_P7kdRabjl1Gp"
    }
  }
}

# ----------------------------------------
# Lambda: Bronze de funcionários
# ----------------------------------------
resource "aws_lambda_function" "bix_processor_lambda" {
  function_name = "bix_api_bronze"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.10"

  filename         = "${path.module}/../lambda/build/lambda_api_bronze.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/build/lambda_api_bronze.zip")
  timeout          = 60

  environment {
    variables = {
      BUCKET = "data-lake-bix-desafio"
    }
  }

  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python310:23"
  ]
}

# ----------------------------------------
# Lambda: Silver de funcionários
# ----------------------------------------
resource "aws_lambda_function" "bix_api_silver" {
  function_name = "bix_api_silver"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.10"

  filename         = "${path.module}/../lambda/build/lambda_package_silver.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/build/lambda_package_silver.zip")
  timeout          = 60

  environment {
    variables = {
      BUCKET = "data-lake-bix-desafio"
    }
  }

  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python310:23"
  ]
}

resource "aws_lambda_function" "bix_categoria_bronze" {
  function_name = "bix_categoria_bronze"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.10"

  filename         = "${path.module}/../lambda/build/lambda_package_categoria_bronze.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/build/lambda_package_categoria_bronze.zip")
  timeout          = 60

  environment {
    variables = {
      BUCKET = "data-lake-bix-desafio"
    }
  }

  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python310:23"
  ]
}

resource "aws_lambda_function" "bix_categoria_silver" {
  function_name = "bix_categoria_silver"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.10"

  filename         = "${path.module}/../lambda/build/lambda_package_categoria_silver.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/build/lambda_package_categoria_silver.zip")
  timeout          = 60

  environment {
    variables = {
      BUCKET = "data-lake-bix-desafio"
    }
  }

  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python310:23"
  ]
}

# ----------------------------------------
# Lambda: COPY para Redshift Silver
# ----------------------------------------
resource "aws_lambda_function" "bix_silver_copy" {
  function_name = "bix_silver_copy"
  role          = aws_iam_role.lambda_redshift_exec_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.10"

  filename         = "${path.module}/../lambda/build/lambda_package_silver_copy.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/build/lambda_package_silver_copy.zip")
  timeout          = 60

  environment {
    variables = {
      REDSHIFT_DATABASE   = "bix_db"
      REDSHIFT_WORKGROUP  = "bix-workgroup"
      REDSHIFT_IAM_ROLE   = aws_iam_role.redshift_copy_role.arn
      BUCKET_NAME         = "data-lake-bix-desafio"
    }
  }
}