resource "aws_launch_template" "app" {
  name_prefix   = "app-template-"
  image_id      = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
apt update
apt install -y docker.io
systemctl start docker
systemctl enable docker
EOF
  )
}
