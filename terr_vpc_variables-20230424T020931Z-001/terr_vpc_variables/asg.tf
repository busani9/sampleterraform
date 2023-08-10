resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "terraform-lc-example-"
  image_id      = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.terraform-key-pair}"
  security_groups = ["${aws_security_group.dev-sg.id}"]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "autoscaling_group_dev" {
  launch_configuration = "${aws_launch_configuration.as_conf.id}"
  min_size             = "${var.autoscaling_group_min_size}"
  max_size             = "${var.autoscaling_group_max_size}"
  target_group_arns    = ["${aws_lb_target_group.front-end.arn}"]
vpc_zone_identifier  = [
    aws_subnet.public.id,
    aws_subnet.private.id
  ]
  tag {
    key                 = "Name"
    value               = "autoscaling-group-dev"
    propagate_at_launch = true
  }
}
