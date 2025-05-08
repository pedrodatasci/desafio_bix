import boto3
import os
import time

# Configurações (pode setar como variáveis de ambiente na Lambda)
DATABASE = os.environ["REDSHIFT_DATABASE"]
WORKGROUP = os.environ["REDSHIFT_WORKGROUP"]
IAM_ROLE = os.environ["REDSHIFT_IAM_ROLE"]
BUCKET = os.environ["BUCKET_NAME"]

TABLES = {
    "funcionario": f"s3://{BUCKET}/silver/funcionario/funcionario.parquet",
    "categoria": f"s3://{BUCKET}/silver/categoria/categoria.parquet",
    "venda": f"s3://{BUCKET}/silver/venda/"
}

client = boto3.client("redshift-data")

def run_statement(sql, return_result=False):
    print(f"Executando: {sql}")
    response = client.execute_statement(
        Database=DATABASE,
        WorkgroupName=WORKGROUP,
        Sql=sql
    )
    
    statement_id = response["Id"]

    while True:
        desc = client.describe_statement(Id=statement_id)
        status = desc["Status"]

        if status in ["FINISHED", "FAILED", "ABORTED"]:
            break
        time.sleep(1)

    if status != "FINISHED":
        error_message = desc.get("Error", "Erro desconhecido")
        print(f"Erro ao executar SQL: {sql}")
        print(f"Mensagem de erro do Redshift: {error_message}")
        raise Exception(f"Falha ao executar SQL: {sql} - {error_message}")

    if return_result:
        result = client.get_statement_result(Id=statement_id)
        rows = result.get("Records", [])
        if rows:
            # Extrai e printa o valor do current_user
            value = rows[0][0].get("stringValue")
            print(f"Resultado: {value}")
            return value

    print("Executado com sucesso.")
    return None

def lambda_handler(event, context):
    try:
        # PRIMEIRA EXECUÇÃO (CRIA USUÁRIO)
        run_statement("SELECT 1;")

        # TRUNCATE
        for table in TABLES:
            run_statement(f"TRUNCATE TABLE silver.{table};")
        
        # COPY
        run_statement(f"""
            COPY silver.funcionario
            FROM '{TABLES['funcionario']}'
            IAM_ROLE '{IAM_ROLE}'
            FORMAT AS PARQUET;
        """)

        run_statement(f"""
            COPY silver.categoria
            FROM '{TABLES['categoria']}'
            IAM_ROLE '{IAM_ROLE}'
            FORMAT AS PARQUET;
        """)

        run_statement(f"""
            COPY silver.venda
            FROM '{TABLES['venda']}'
            IAM_ROLE '{IAM_ROLE}'
            FORMAT AS PARQUET;
        """)

        return {
            "status": "ok",
            "message": "Tabelas truncadas e carregadas com sucesso"
        }

    except Exception as e:
        print(e)
        raise Exception(f"Erro na copy das tabelas: {e}")