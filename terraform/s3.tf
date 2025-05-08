resource "aws_s3_bucket" "bix_data_lake" {
  bucket = "data-lake-bix-desafio"

  tags = {
    Name        = "Data Lake Bix Desafio"
    Environment = "dev"
  }
}
