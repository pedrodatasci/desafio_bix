resource "aws_sfn_state_machine" "orquestrador_dados" {
  name     = "orquestrador-dados"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "Orquestra as coletas e transformacoes"
    StartAt = "ParallelCollect"
    States = {
      ParallelCollect = {
        Type = "Parallel"
        Branches = [

          # === Fluxo 1: API -> Bronze -> Silver ===
          {
            StartAt = "LambdaApiColeta"
            States = {
              LambdaApiColeta = {
                Type = "Task"
                Resource = "arn:aws:states:::lambda:invoke"
                Parameters = {
                  FunctionName = aws_lambda_function.bix_api_collector.arn
                }
                Next = "LambdaApiBronze"
              }
              LambdaApiBronze = {
                Type = "Task"
                Resource = "arn:aws:states:::lambda:invoke"
                Parameters = {
                  FunctionName = aws_lambda_function.bix_processor_lambda.arn
                }
                Next = "LambdaApiSilver"
              }
              LambdaApiSilver = {
                Type = "Task"
                Resource = "arn:aws:states:::lambda:invoke"
                Parameters = {
                  FunctionName = aws_lambda_function.bix_api_silver.arn
                }
                End = true
              }
            }
          },

          # === Fluxo 2: Categoria Parquet -> Bronze -> Silver ===
          {
            StartAt = "LambdaCategoriaBronze"
            States = {
              LambdaCategoriaBronze = {
                Type = "Task"
                Resource = "arn:aws:states:::lambda:invoke"
                Parameters = {
                  FunctionName = aws_lambda_function.bix_categoria_bronze.arn
                }
                Next = "LambdaCategoriaSilver"
              }
              LambdaCategoriaSilver = {
                Type = "Task"
                Resource = "arn:aws:states:::lambda:invoke"
                Parameters = {
                  FunctionName = aws_lambda_function.bix_categoria_silver.arn
                }
                End = true
              }
            }
          },

          # === Fluxo 3: DB -> Glue Bronze -> Glue Silver ===
          {
            StartAt = "LambdaDbColeta"
            States = {
              LambdaDbColeta = {
                Type = "Task"
                Resource = "arn:aws:states:::lambda:invoke"
                Parameters = {
                  FunctionName = aws_lambda_function.bix_db_collector.arn
                }
                Next = "GlueBronze"
              }
              GlueBronze = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = aws_glue_job.bix_vendas_bronze.name
                }
                Next = "GlueSilver"
              }
              GlueSilver = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = aws_glue_job.bix_vendas_silver.name
                }
                End = true
              }
            }
          }
        ]
        Next = "LambdaRedshiftCopy"
      }

      LambdaRedshiftCopy = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.bix_silver_copy.arn
        }
        End = true
      }
    }
  })
}
