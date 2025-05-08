resource "aws_redshiftdata_statement" "create_schema" {
  database       = aws_redshiftserverless_namespace.this.db_name
  workgroup_name = aws_redshiftserverless_workgroup.this.workgroup_name

  sql = "CREATE SCHEMA IF NOT EXISTS silver AUTHORIZATION admin_bix;"

  depends_on = [aws_redshiftdata_statement.create_superuser]
}

resource "aws_redshiftdata_statement" "grant_usage_readonly" {
  database       = aws_redshiftserverless_namespace.this.db_name
  workgroup_name = aws_redshiftserverless_workgroup.this.workgroup_name

  sql = <<-SQL
    GRANT USAGE ON SCHEMA silver TO readonly_bix;
    GRANT SELECT ON ALL TABLES IN SCHEMA silver TO readonly_bix;
    ALTER DEFAULT PRIVILEGES IN SCHEMA silver GRANT SELECT ON TABLES TO readonly_bix;
  SQL

  depends_on = [
    aws_redshiftdata_statement.create_schema,
    aws_redshiftdata_statement.create_readonly
  ]
}
