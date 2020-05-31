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

provider "random" {
  version = "2.2"
}

resource "aws_dynamodb_table" "tfc_example_table" {
  name = "petstore-table"

  read_capacity  = 5
  write_capacity = 5
  hash_key       = "UUID"

  attribute {
    name = "UUID"
    type = "S"
  }

}
