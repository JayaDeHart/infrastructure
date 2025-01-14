terraform {
  backend "s3" {
    bucket = "todo-backend-state"
    dynamodb_table = "state-lock"
    key = "global/mystatefile/terraform.tfstate"
    region = "us-west-2"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "todo_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"

  tags = {
    Name = "todo-server"
  }

  vpc_security_group_ids = [aws_security_group.todo_server_sg.id]
}

resource "aws_security_group" "todo_server_sg" {
  name        = "todo-server-sg"
  description = "Allow traffic from todo-server to RDS"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "todo_rds_sg" {
  name        = "todo-rds-sg"
  description = "Allow traffic from todo-server"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.todo_server_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "todo_mysql_db" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "admin"

  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false
  manage_master_user_password = true
  vpc_security_group_ids = [aws_security_group.todo_rds_sg.id]

  tags = {
    Name = "todo-mysql-db"
  }
}
