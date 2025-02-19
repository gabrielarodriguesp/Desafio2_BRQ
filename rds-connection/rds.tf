resource "aws_security_group" "sg-rds" {
  name_prefix = "rds-"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_instance" "mysql" {
  engine                 = "mysql"
  db_name                = "pizzariadb"
  identifier             = "pizzariadb"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  username               = var.db-username
  password               = var.db-password
  multi_az               = false
  vpc_security_group_ids = [aws_security_group.sg-rds.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
}