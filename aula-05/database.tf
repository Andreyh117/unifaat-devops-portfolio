resource "aws_db_subnet_group" "main" {
  name       = "technova-db-6325231"
  subnet_ids = [for k, v in local.subnets : aws_subnet.main[k].id if !v.public]
  tags       = { Name = "technova-db-subnets" }
}
resource "aws_db_instance" "main" {
  identifier             = "technova-db-6325231"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  multi_az               = false
  publicly_accessible    = false
  storage_encrypted      = true
  skip_final_snapshot    = true
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  tags                   = { Name = "technova-postgres" }
}
