resource "aws_redshiftserverless_namespace" "this" {
  namespace_name = "bix-namespace"
  db_name        = "bix_db"
}

resource "aws_redshiftserverless_workgroup" "this" {
  workgroup_name         = "bix-workgroup"
  namespace_name         = aws_redshiftserverless_namespace.this.namespace_name
  publicly_accessible    = true
  base_capacity          = 8
  enhanced_vpc_routing   = false

  tags = {
    Environment = "dev"
  }
}