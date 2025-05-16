# RDS Security Group (allow MySQL from EC2 only)
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL from EC2 SG only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "MySQL from EC2"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# DB Subnet Group (to span both private subnets)
resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "wordpress-db-subnet-group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "wordpress" {
  identifier              = "wordpress-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "Wordpress123!"  # Replace with variable in production
  db_name                 = "wordpress"
  db_subnet_group_name    = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false

  tags = {
    Name = "wordpress-db"
  }
}
