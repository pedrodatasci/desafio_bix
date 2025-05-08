import boto3
import pandas as pd
import io
import os
import uuid
from datetime import datetime

s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET"]

def lambda_handler(event, context):
    today_str = datetime.utcnow().strftime("%Y-%m-%d")
    key_raw = f"raw/{today_str}/categoria.parquet"
    key_bronze = f"bronze/categoria/categoria_{uuid.uuid4()}.parquet"

    try:
        obj = s3.get_object(Bucket=BUCKET, Key=key_raw)
        df = pd.read_parquet(io.BytesIO(obj["Body"].read()))

        buffer = io.BytesIO()
        df.to_parquet(buffer, index=False)
        buffer.seek(0)

        s3.put_object(Bucket=BUCKET, Key=key_bronze, Body=buffer.getvalue())
        print(f"{len(df)} registros salvos em {key_bronze}")
        return {"statusCode": 200, "body": f"{len(df)} registros bronzeados."}
    except Exception as e:
        raise Exception(f"Erro: {e}")
