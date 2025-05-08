import sys
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from awsglue.utils import getResolvedOptions
from pyspark.sql.window import Window
import pyspark.sql.functions as F

args = getResolvedOptions(sys.argv, ['S3_INPUT_PATH', 'S3_OUTPUT_PATH'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

df = spark.read.parquet(args['S3_INPUT_PATH'])

window_spec = Window.partitionBy("id_venda").orderBy(F.col("data_venda").desc())
df_ranked = df.withColumn("row_number", F.row_number().over(window_spec))
df_dedup = df_ranked.filter(F.col("row_number") == 1).drop("row_number")

df_dedup.write.mode("overwrite").parquet(args['S3_OUTPUT_PATH'])
