resource "aws_alb" "rearc-alb" {
  name               = "rearc-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.rearc-alb-sg.id]
  subnets            = [aws_subnet.rearc-subnet-1.id, aws_subnet.rearc-subnet-2.id]
}

resource "aws_alb_target_group" "rearc-target-group" {
  name        = "rearc-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.rearc-vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  depends_on = [aws_alb.rearc-alb]
}

resource "aws_acm_certificate" "myrichmondlaw.com" {                         # "rearc-ssl-cert" {
  domain_name       = "myrichmondlaw.com"
  validation_method = "DNS"

  validation_option {
    domain_name       = "myrichmondlaw.com"
    validation_domain = "myrichmondlaw.com"
  }
}

resource "aws_alb_listener" "rearc-http-listener" {
  load_balancer_arn = aws_alb.rearc-alb.arn
  port              = "80"
  protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }

    target_group_arn = aws_alb_target_group.rearc-target-group.arn
    type             = "forward"
  }
}

# # this creates an access point to the load balancer using HTTPS protocol.

resource "aws_alb_listener" "rearc-https-listener" {
  load_balancer_arn = aws_alb.rearc-alb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"

  cerificate_arn = aws_acm_certificate.myrichmondlaw.arn


  default_action {
    target_group_arn = aws_alb_target_group.rearc-target-group.arn
    type = "forward"
  }
}


