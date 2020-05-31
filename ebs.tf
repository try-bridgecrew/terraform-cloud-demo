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
