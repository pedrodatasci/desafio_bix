resource "aws_glue_job" "bix_vendas_bronze" {
  name     = "bix_vendas_bronze"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://data-lake-bix-desafio/glue_jobs/bix_vendas_bronze.py"
    python_version  = "3"
  }

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  default_arguments = {
    "--job-language"    = "python"
    "--S3_INPUT_PATH"   = "s3://data-lake-bix-desafio/raw/"
    "--S3_OUTPUT_PATH"  = "s3://data-lake-bix-desafio/bronze/venda/"
  }
}

resource "aws_glue_job" "bix_vendas_silver" {
  name     = "bix_vendas_silver"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://data-lake-bix-desafio/glue_jobs/bix_vendas_silver.py"
    python_version  = "3"
  }

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  default_arguments = {
    "--job-language"    = "python"
    "--S3_INPUT_PATH"   = "s3://data-lake-bix-desafio/bronze/venda/"
    "--S3_OUTPUT_PATH"  = "s3://data-lake-bix-desafio/silver/venda/"
  }
}
