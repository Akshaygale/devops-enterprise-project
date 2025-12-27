resource "aws_autoscaling_group" "app_asg" {
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  desired_capacity   = 2
  min_size           = 2
  max_size           = 4

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.blue.arn]
}
