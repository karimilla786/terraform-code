resource "aws_launch_configuration" "as_conf"{
  name = "terraform-lc-example"
  image_id = "ami-0cca134ec43cf708f" # Amazon Linux
  instance_type = "t2.micro"
  key_name = "aws_key"
	#user_data = file("apache-install.sh")
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
   EOF
   security_groups = [ aws_security_group.dev-vpc-sg.id ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscale_group" {
  name                 = "terraform-test"
  launch_configuration = "${aws_launch_configuration.as_conf.id}"
  vpc_zone_identifier =  aws_subnet.private.*.id
#  availability_zones = "${var.avail_zones[*]}" 
  min_size = 1
  max_size = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  tag {
    key = "Name"
    value = "autoscale"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.autoscale_group.id
#  elb                    = aws_lb.alb.id
  alb_target_group_arn   = aws_alb_target_group.group.arn
  depends_on =  [aws_lb.alb]
}
