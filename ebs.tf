resource "aws_ebs_volume" "web_host_storage" {
  availability_zone = "${var.availability_zone}"
  size              = 1
  tags = {
    Name = "${local.resource_prefix.value}-ebs"
  }
}
