# -------------------------------
# Gerar senhas seguras com números
# -------------------------------
resource "random_password" "superuser_pwd" {
  length      = 16
  special     = false
  number      = true
  min_numeric = 2
}

resource "random_password" "readonly_pwd" {
  length      = 16
  special     = false
  number      = true
  min_numeric = 2
}

# -------------------------------
# Gerar sufixo aleatório para nomes únicos
# -------------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

# -------------------------------
# Secrets para armazenar credenciais (com sufixo)
# -------------------------------
resource "aws_secretsmanager_secret" "superuser" {
  name = "redshift_superuser_${random_id.suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "superuser_version" {
  secret_id     = aws_secretsmanager_secret.superuser.id
  secret_string = jsonencode({
    username = "admin_bix"
    password = random_password.superuser_pwd.result
  })
}

resource "aws_secretsmanager_secret" "readonly" {
  name = "redshift_readonly_${random_id.suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "readonly_version" {
  secret_id     = aws_secretsmanager_secret.readonly.id
  secret_string = jsonencode({
    username = "readonly_bix"
    password = random_password.readonly_pwd.result
  })
}

# -------------------------------
# Criar usuários no Redshift Serverless
# (atenção: esses blocos devem ser comentados se o usuário já existir)
# -------------------------------
resource "aws_redshiftdata_statement" "create_superuser" {
  database       = aws_redshiftserverless_namespace.this.db_name
  workgroup_name = aws_redshiftserverless_workgroup.this.workgroup_name

  sql = <<-SQL
    DROP USER IF EXISTS admin_bix;
    CREATE USER admin_bix PASSWORD '${random_password.superuser_pwd.result}' CREATEUSER;
  SQL

  depends_on = [aws_redshiftserverless_workgroup.this]
}

resource "aws_redshiftdata_statement" "create_readonly" {
  database       = aws_redshiftserverless_namespace.this.db_name
  workgroup_name = aws_redshiftserverless_workgroup.this.workgroup_name

  sql = <<-SQL
    DROP USER IF EXISTS readonly_bix;
    CREATE USER readonly_bix PASSWORD '${random_password.readonly_pwd.result}';
  SQL

  depends_on = [aws_redshiftserverless_workgroup.this]
}
