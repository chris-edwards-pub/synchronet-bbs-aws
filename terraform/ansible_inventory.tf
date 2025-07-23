resource "aws_s3_object" "ansible_inventory" {
  bucket  = "synchronet-bbs"
  key     = "ansible-sbbs/hosts.ini"
  content = templatefile("${path.module}/inventory.tpl", {
    instance_ip = aws_instance.sbbs_server.public_ip
  })
}
