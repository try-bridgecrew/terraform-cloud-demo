resource "aws_ebs_volume" "web_host_storage" {
  availability_zone = "us-west-2a"
  size              = 10
  tags = {
    Name = "bridgecrew-terraform-cloud-ebs"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}
provider "aws" {
  version = "2.33.0"

  region = var.aws_region
}

provider "random" {
  version = "2.2"
}

resource "random_pet" "table_name" {}

resource "aws_dynamodb_table" "tfc_example_table" {
  name = "${var.db_table_name}-${random_pet.table_name.id}"

  read_capacity  = var.db_read_capacity
  write_capacity = var.db_write_capacity
  hash_key       = "UUID"

  attribute {
    name = "UUID"
    type = "S"
  }

  tags = {
    user_name = var.tag_user_name
  }
}
