import json
import boto3
import psycopg2
from datetime import datetime, timedelta
import os

s3 = boto3.client("s3")
BUCKET = "data-lake-bix-desafio"
TABLE_NAME = "public.venda"

DB_CONFIG = {
    "host": os.environ["DB_HOST"],
    "database": os.environ["DB_NAME"],
    "user": os.environ["DB_USER"],
    "password": os.environ["DB_PASS"],
    "port": os.environ.get("DB_PORT", 5432),
}

def lambda_handler(event, context):
    today = datetime.utcnow().strftime("%Y-%m-%d")
    s3_key = f"raw/{today}/venda.json"

    # Verifica se já existem arquivos de vendas anteriores
    response = s3.list_objects_v2(Bucket=BUCKET, Prefix="raw/")
    previous_dates = sorted({
        obj["Key"].split("/")[1]
        for obj in response.get("Contents", [])
        if obj["Key"].endswith("venda.json")
    }, reverse=True)

    # Define a query com base no histórico
    if previous_dates:
        last_date = datetime.strptime(previous_dates[0], "%Y-%m-%d")
        window_start = (last_date - timedelta(days=3)).strftime("%Y-%m-%d")
        query = f"SELECT * FROM {TABLE_NAME} WHERE data_venda >= '{window_start}'"
        print(f"Executando coleta incremental a partir de {window_start}")
    else:
        print("Primeira execução: coletando todos os dados.")
        query = f"SELECT * FROM {TABLE_NAME}"

    # Conectar ao banco e executar a query
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute(query)
        colnames = [desc[0] for desc in cur.description]
        rows = cur.fetchall()
        cur.close()
        conn.close()
    except Exception as e:
        raise Exception(f"Erro ao conectar ou executar a query: {e}")

    # Formatar resultados
    data = [dict(zip(colnames, row)) for row in rows]

    # Salvar no S3
    s3.put_object(
        Bucket=BUCKET,
        Key=s3_key,
        Body=json.dumps(data, default=str),
        ContentType="application/json"
    )

    print(f"{len(data)} registros salvos em s3://{BUCKET}/{s3_key}")

    return {
        "statusCode": 200,
        "body": f"{len(data)} registros salvos em s3://{BUCKET}/{s3_key}"
    }