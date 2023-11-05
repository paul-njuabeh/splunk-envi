resource "aws_route53_zone" "training_zone" {
    name = "<your domain name>"
}


resource "aws_route53_record" "instance_records" {
  for_each = {
    for i in aws_instance.splunk_instances : 
      i.tags["Name"] => i.public_ip
  }

  zone_id = aws_route53_zone.training_zone.zone_id
  name    = "${each.key}"
  type    = "A"
  ttl     = 300
  records = [each.value]
}

