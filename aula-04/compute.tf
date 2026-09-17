data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_key_pair" "main" {
  key_name_prefix = "technova-04-"
  public_key      = file(pathexpand(var.public_key_path))
  tags            = { Name = "technova-key" }
}
resource "aws_instance" "api" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main["public_a"].id
  vpc_security_group_ids      = [aws_security_group.api.id]
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = "LabInstanceProfile"
  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    tags        = { Name = "technova-api-root", Project = "TechNova", Aula = "04", Environment = "development", ManagedBy = "Terraform", Owner = "6325231" }
  }
  tags       = { Name = "technova-api" }
  depends_on = [aws_route_table_association.public]
}
