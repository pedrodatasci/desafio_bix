from datetime import datetime
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from pyspark.sql.functions import from_json, col, explode, to_date
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, ArrayType, IntegerType

# Contextos
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Data de referência no formato YYYY-MM-DD
data_ref = datetime.today().strftime("%Y-%m-%d")

# Caminho raw
raw_path = f"s3://data-lake-bix-desafio/raw/{data_ref}/venda.json"

# Schema do array de vendas
schema = StructType([
    StructField("id_venda", IntegerType()),
    StructField("id_funcionario", IntegerType()),
    StructField("id_categoria", IntegerType()),
    StructField("data_venda", StringType()),
    StructField("venda", DoubleType())
])

# Leitura como texto + parsing do array JSON
df_txt = spark.read.text(raw_path)
df_array = df_txt.select(from_json(col("value"), ArrayType(schema)).alias("vendas"))
df_exploded = df_array.select(explode("vendas").alias("venda"))

# Seleção final + formatação
df_final = df_exploded.select("venda.*") \
    .withColumn("data_venda", to_date("data_venda"))

# Escrita na bronze em modo append, sem particionamento
df_final.write.mode("append").parquet("s3://data-lake-bix-desafio/bronze/venda/")
