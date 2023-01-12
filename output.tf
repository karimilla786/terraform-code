output "alb-dns"{
description = " ALB dns name"
value = aws_lb.alb.dns_name
}
