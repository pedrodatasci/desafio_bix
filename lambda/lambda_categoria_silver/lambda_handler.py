import boto3
import pandas as pd
import io
import os

s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET"]
PREFIX = "bronze/categoria/"
OUTPUT_KEY = "silver/categoria/categoria.parquet"

def lambda_handler(event, context):
    try:
        response = s3.list_objects_v2(Bucket=BUCKET, Prefix=PREFIX)
        files = [item["Key"] for item in response.get("Contents", []) if item["Key"].endswith(".parquet")]

        if not files:
            raise Exception("Nenhum arquivo encontrado.")

        dfs = []
        for key in files:
            obj = s3.get_object(Bucket=BUCKET, Key=key)
            df = pd.read_parquet(io.BytesIO(obj["Body"].read()))
            dfs.append(df)

        full_df = pd.concat(dfs, ignore_index=True)
        dedup_df = full_df.drop_duplicates(subset="id")

        out_buffer = io.BytesIO()
        dedup_df.to_parquet(out_buffer, index=False)
        out_buffer.seek(0)

        s3.put_object(Bucket=BUCKET, Key=OUTPUT_KEY, Body=out_buffer.getvalue())
        print(f"{len(dedup_df)} registros salvos em {OUTPUT_KEY}")
        return {"statusCode": 200, "body": f"{len(dedup_df)} registros deduplicados."}
    except Exception as e:
        raise Exception(f"Erro: {e}")
