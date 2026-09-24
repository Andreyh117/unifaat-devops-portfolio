data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
module "vpc" {
  source       = "../../modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  subnets      = var.subnets
}
module "api_sg" {
  source       = "../../modules/security-group"
  name         = "${var.project_name}-${var.environment}-api-sg"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  ingress_rules = [{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}
module "rds_sg" {
  source       = "../../modules/security-group"
  name         = "${var.project_name}-${var.environment}-rds-sg"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  ingress_rules = [{
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    description     = "PostgreSQL somente da EC2"
    security_groups = [module.api_sg.sg_id]
  }]
}
module "api_server" {
  source             = "../../modules/ec2"
  instance_name      = "${var.project_name}-${var.environment}-api"
  project_name       = var.project_name
  environment        = var.environment
  instance_type      = "t2.micro"
  ami_id             = data.aws_ami.amazon_linux.id
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.api_sg.sg_id]
  key_name           = var.key_name
}
module "database" {
  source             = "../../modules/rds"
  project_name       = var.project_name
  environment        = var.environment
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.rds_sg.sg_id]
  instance_class     = "db.t3.micro"
}
