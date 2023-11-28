# --- loadbalancing/main.tf ---

resource "aws_lb" "dev_lb" {
  name            = "dev-loadbalancer"
  subnets         = var.public_subnets
  security_groups = var.public_sg
  idle_timeout    = var.idle_timeout
}

resource "aws_lb_target_group" "dev_tg" {
  name     = "dev-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port #80
  protocol = var.tg_protocol
  vpc_id   = var.dev_vpc.id
  health_check {
    healthy_threshold   = var.lb_healthy_threshold   #2
    unhealthy_threshold = var.lb_unhealthy_threshold #2
    timeout             = var.lb_timeout             #3
    interval            = var.lb_interval            #3
    protocol            = var.tg_protocol
  }
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "dev_lb_listener" {
  load_balancer_arn = aws_lb.dev_lb.arn
  port              = var.listener_port     #80
  protocol          = var.listener_protocol # "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_tg.arn
  }
}