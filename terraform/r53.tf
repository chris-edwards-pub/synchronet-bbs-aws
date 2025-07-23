# Route 53 Hosted Zone for c64.pub
resource "aws_route53_zone" "c64_pub" {
  name = "c64.pub"

  tags = {
    Name        = "c64.pub"
    Environment = var.environment
  }
}

# A record for sbbs.c64.pub pointing to EC2 instance
resource "aws_route53_record" "sbbs" {
  zone_id = aws_route53_zone.c64_pub.zone_id
  name    = "sbbs.c64.pub"
  type    = "A"
  ttl     = 300
  records = [aws_instance.sbbs_server.public_ip]
}

# Output the name servers for the hosted zone
output "c64_pub_name_servers" {
  value       = aws_route53_zone.c64_pub.name_servers
  description = "Name servers for c64.pub domain - update these at your domain registrar"
}

output "sbbs_fqdn" {
  value       = aws_route53_record.sbbs.fqdn
  description = "Fully qualified domain name for the SBBS server"
}
