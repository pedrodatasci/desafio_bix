import boto3
import pandas as pd
import io
import os
import pyarrow as pa
import pyarrow.parquet as pq

s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET"]
PREFIX = "bronze/funcionario/"
OUTPUT_KEY = "silver/funcionario/funcionario.parquet"

def lambda_handler(event, context):
    try:
        # Listar todos os arquivos .parquet na pasta bronze/funcionarios/
        response = s3.list_objects_v2(Bucket=BUCKET, Prefix=PREFIX)
        files = [item["Key"] for item in response.get("Contents", []) if item["Key"].endswith(".parquet")]

        if not files:
            raise Exception("Nenhum arquivo Parquet encontrado.")

        # Ler e concatenar todos os arquivos Parquet
        dfs = []
        for key in files:
            obj = s3.get_object(Bucket=BUCKET, Key=key)
            buffer = io.BytesIO(obj["Body"].read())
            df = pd.read_parquet(buffer)
            dfs.append(df)

        full_df = pd.concat(dfs, ignore_index=True)

        # Remover duplicatas
        dedup_df = full_df.drop_duplicates(subset="id")

        # Salvar em buffer como Parquet
        out_buffer = io.BytesIO()
        dedup_df.to_parquet(out_buffer, index=False)
        out_buffer.seek(0)

        # Enviar para S3 em silver/
        s3.put_object(Bucket=BUCKET, Key=OUTPUT_KEY, Body=out_buffer.getvalue())

        print(f"{len(dedup_df)} registros salvos em {OUTPUT_KEY}")
        return {"statusCode": 200, "body": f"{len(dedup_df)} registros salvos."}

    except Exception as e:
        raise Exception(f"Erro: {e}")
