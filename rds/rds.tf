resource "aws_db_instance" "pokemon_db" {
  identifier             = "pokemon-db"
  db_name                = "pokemon"
  engine                 = "mariadb"
  engine_version         = "10.6.11"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  username               = "admin"
  password               = "my_cool_secret"
  skip_final_snapshot    = true
  port                   = 3306
  publicly_accessible    = false
  availability_zone      = "ap-south-1a"
  vpc_security_group_ids = [aws_security_group.database_security_group_rds.id]
}


resource "aws_security_group" "database_security_group_rds" {
  name = "rds-ec2-sg"

  ingress {
    from_port       = 3306
    protocol        = "tcp"
    to_port         = 3306
    security_groups = [var.instance_sg]
  }

}