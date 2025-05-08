@echo off
set BUCKET=data-lake-bix-desafio
set S3_PATH=s3://%BUCKET%/glue_jobs

cd ..
cd "./glue_jobs"

echo Subindo Glue Jobs para o S3...
aws s3 cp "bix_vendas_bronze.py" "%S3_PATH%/bix_vendas_bronze.py"
aws s3 cp "bix_vendas_silver.py" "%S3_PATH%/bix_vendas_silver.py"

echo Upload concluído com sucesso.
pause