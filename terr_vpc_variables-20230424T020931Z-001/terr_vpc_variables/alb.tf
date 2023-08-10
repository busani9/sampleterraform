resource "aws_lb" "my-alb" {
  name            = "my-alb"
  internal        = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.dev-sg.id]
  subnets         = [aws_subnet.public.id, aws_subnet.private.id]

  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_target_group" "front-end" {
  name     = "front-end"
  port     = 8989
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.dev.id}"
}


resource "aws_lb_listener" "my-listener" {
  load_balancer_arn = aws_lb.my-alb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.front-end.arn
  }
}
