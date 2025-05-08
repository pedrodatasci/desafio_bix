# ------------------------------------------------------------
# Lambda Execution Role
# ------------------------------------------------------------
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role_bix"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name = "lambda_s3_access_bix"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::data-lake-bix-desafio",
        "arn:aws:s3:::data-lake-bix-desafio/*"
      ]
    }]
  })
}

resource "aws_iam_policy" "lambda_logs_policy" {
  name = "lambda_logs_policy_bix"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}

resource "aws_iam_policy" "lambda_db_connect_policy" {
  name = "lambda_db_connect_policy_bix"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["rds-db:connect"],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_db_connect_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_db_connect_policy.arn
}

resource "aws_iam_role" "lambda_redshift_exec_role" {
  name = "lambda-redshift-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_redshift_exec_policy" {
  name = "lambda-redshift-exec-policy"
  role = aws_iam_role.lambda_redshift_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "redshift-data:ExecuteStatement",
          "redshift-data:GetStatementResult",
          "redshift-data:DescribeStatement",
          "redshift-data:CancelStatement",
          "redshift-serverless:GetCredentials"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
        "arn:aws:s3:::${aws_s3_bucket.bix_data_lake.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.bix_data_lake.bucket}/*"
        ]
      }
    ]
  })
}

# ------------------------------------------------------------
# Redshift Role para COPY de dados via S3
# ------------------------------------------------------------
resource "aws_iam_role" "redshift_copy_role" {
  name = "redshift-s3-copy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "redshift.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "redshift_copy_policy" {
  name = "redshift-copy-s3-access"
  role = aws_iam_role.redshift_copy_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::${aws_s3_bucket.bix_data_lake.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.bix_data_lake.bucket}/*"
      ]
    }]
  })
}

# ------------------------------------------------------------
# Step Function Role e Policy
# ------------------------------------------------------------
resource "aws_iam_role" "step_function_role" {
  name = "step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "step_function_policy" {
  name = "step-function-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["lambda:InvokeFunction"],
        Resource = [
          aws_lambda_function.bix_api_collector.arn,
          aws_lambda_function.bix_processor_lambda.arn,
          aws_lambda_function.bix_api_silver.arn,
          aws_lambda_function.bix_categoria_bronze.arn,
          aws_lambda_function.bix_categoria_silver.arn,
          aws_lambda_function.bix_db_collector.arn,
          aws_lambda_function.bix_silver_copy.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:GetJob"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_step_policy" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}