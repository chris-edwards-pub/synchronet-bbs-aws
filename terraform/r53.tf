# Route 53 Hosted Zone for c64.pub
resource "aws_route53_zone" "c64_pub" {
  name = "c64.pub"

  tags = {
    Name        = "c64.pub"
    Environment = var.environment
  }
}


# A record for c64.pub pointing to Elastic IP
resource "aws_route53_record" "c64_pub" {
  zone_id = aws_route53_zone.c64_pub.zone_id
  name    = "c64.pub"
  type    = "A"
  ttl     = 600
  records = [aws_eip.sbbs_eip.public_ip]
}

# CNAME for bbs.c64.pub pointing to c64.pub
resource "aws_route53_record" "sbbs" {
  zone_id = aws_route53_zone.c64_pub.zone_id
  name    = "bbs.c64.pub"
  type    = "CNAME"
  ttl     = 600
  records = ["c64.pub."]
}

# CNAME for www.c64.pub pointing to c64.pub
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.c64_pub.zone_id
  name    = "www.c64.pub"
  type    = "CNAME"
  ttl     = 600
  records = ["c64.pub."]
}

# CNAME for xterm.c64.pub pointing to c64.pub
resource "aws_route53_record" "xterm" {
  zone_id = aws_route53_zone.c64_pub.zone_id
  name    = "xterm.c64.pub"
  type    = "CNAME"
  ttl     = 600
  records = ["c64.pub."]
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
