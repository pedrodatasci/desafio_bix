import json
import urllib3
import boto3
from time import sleep
from datetime import datetime

s3 = boto3.client("s3")
http = urllib3.PoolManager()

ENDPOINT = "https://us-central1-bix-tecnologia-prd.cloudfunctions.net/api_challenge_junior?id="
BUCKET = "data-lake-bix-desafio"

def lambda_handler(event, context):
    collected_data = []
    id_ = 1

    while True:
        url = f"{ENDPOINT}{id_}"
        try:
            response = http.request("GET", url)

            if response.status != 200:
                print(f"ID {id_} - Requisição falhou com status {response.status}")
                break

            data = response.data.decode("utf-8")
            if "The argument is not correct" in data:
                print(f"ID {id_} - Argumento inválido.")
                break

            print(f"ID {id_} - Sucesso")
            collected_data.append({"id": id_, "name": data})
            id_ += 1

        except Exception as e:
            raise Exception(f"Erro no ID {id_}: {e}")

        sleep(0.2)

    # Gerar chave com a data de hoje (ex: raw/2025-05-05/funcionarios.json)
    today_str = datetime.utcnow().strftime("%Y-%m-%d")
    key = f"raw/{today_str}/funcionario.json"

    # Salvar no S3
    s3.put_object(
        Bucket=BUCKET,
        Key=key,
        Body=json.dumps(collected_data),
        ContentType="application/json"
    )

    return {
        "statusCode": 200,
        "body": f"{len(collected_data)} registros salvos em s3://{BUCKET}/{key}"
    }
