#Define the launch template
resource "aws_launch_template" "Cocoplanner" {
  name_prefix   = "Cocoplanner-"
  image_id      = var.ami
  instance_type = "t2.small"
  key_name      = aws_key_pair.main_key.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10
      volume_type = "gp3"
      encrypted   = true
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
    subnet_id                   = aws_subnet.public[0].id
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("userdata.sh", {
    efs_id = aws_efs_file_system.Cocoplanner.id
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Cocoplanner"
    }
  }
}

resource "aws_autoscaling_group" "Cocoplanner" {
  name                = "Cocoplanner"
  vpc_zone_identifier = aws_subnet.public[*].id

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size         = 2
  max_size         = 2
  desired_capacity = 2

  tag {
    key                 = "Name"
    value               = "Cocoplanner"
    propagate_at_launch = true
  }

  launch_template {
    id      = aws_launch_template.Cocoplanner.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup = 300
    }
  }
}

# Retrieve the instances in the ASG to get IPs
data "aws_instances" "asg_instances" {
  instance_tags = {
    "aws:autoscaling:groupName" = aws_autoscaling_group.Cocoplanner.name
  }

  instance_state_names = ["running"]

  depends_on = [aws_autoscaling_group.Cocoplanner]
} 