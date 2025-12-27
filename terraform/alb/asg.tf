# Launch Template
resource "aws_launch_template" "app" {
  name          = "app-template"
  image_id      = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t3.micro"
  key_name      = var.ssh_key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker -y
              service docker start
              docker login -u AWS -p $(aws ecr get-login-password --region ${var.aws_region}) ${var.ecr_repo}
              docker pull ${var.ecr_repo}:latest
              docker run -d -p 80:80 ${var.ecr_repo}:latest
              EOF
}

# Blue ASG
resource "aws_autoscaling_group" "blue_asg" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.blue.arn]
}

# Green ASG (starts with 0)
resource "aws_autoscaling_group" "green_asg" {
  desired_capacity    = 0
  max_size            = 2
  min_size            = 0
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.green.arn]
}
