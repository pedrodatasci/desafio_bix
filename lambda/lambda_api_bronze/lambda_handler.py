import boto3
import pandas as pd
import io
import os
import uuid
from datetime import datetime

s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET"]

def lambda_handler(event, context):
    # Data de hoje para buscar na raw
    today_str = datetime.utcnow().strftime("%Y-%m-%d")
    key_raw = f"raw/{today_str}/funcionario.json"
    key_bronze = f"bronze/funcionario/funcionario_{uuid.uuid4()}.parquet"

    try:
        # Ler arquivo JSON da camada raw
        response = s3.get_object(Bucket=BUCKET, Key=key_raw)
        content = response["Body"].read().decode("utf-8")

        # Carregar no Pandas
        df = pd.read_json(io.StringIO(content))

        # Salvar como Parquet
        buffer = io.BytesIO()
        df.to_parquet(buffer, index=False)
        buffer.seek(0)

        # Enviar para S3 na bronze
        s3.put_object(Bucket=BUCKET, Key=key_bronze, Body=buffer.getvalue())

        print(f"{len(df)} registros gravados em {key_bronze}")
        return {"statusCode": 200, "body": f"Sucesso. Registros: {len(df)}"}

    except Exception as e:
        raise Exception(f"Erro ao processar funcionarios.json: {e}")
        