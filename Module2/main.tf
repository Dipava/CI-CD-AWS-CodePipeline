module "rdsdb" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.0.3"
  # depends_on = [data.terraform_remote_state.vpc]
  identifier = var.db_instance_identifier
  db_name  = var.db_name
  db_subnet_group_name = data.terraform_remote_state.vpc.outputs.database_subnet_group_name
  username = var.db_username
  password = var.db_password
  multi_az               = true
  subnet_ids             = data.terraform_remote_state.vpc.outputs.database_subnets
  vpc_security_group_ids = [data.terraform_remote_state.rdsdb_sg.outputs.rdsdb_sg_group_id]
  port     = 3306
  engine               = "mysql"
  engine_version       = "8.0.27"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = "db.t2.micro"
  performance_insights_enabled = false
  allocated_storage     = 20
  max_allocated_storage = 100
  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = true
  create_random_password     = false
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_encrypted       = false
  create_monitoring_role  = false
  monitoring_interval     = 60

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  db_instance_tags = {
    "Sensitive" = "high"
  }
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
}