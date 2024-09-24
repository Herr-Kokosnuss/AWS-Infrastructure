#TF_VAR_db_username="froggy-996"
#TF_VAR_db_password="froggy996"

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  db_name             = "example_database"
  # How should we set the username and password?
  username = var.db_username
  password = var.db_password
}