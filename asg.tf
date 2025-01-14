#Define the launch template
resource "aws_launch_template" "Cocoplanner" {
  name_prefix   = "Cocoplanner-"
  image_id      = var.ami
  instance_type = "t2.small"
  key_name      = aws_key_pair.main_key.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 15
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
  vpc_zone_identifier = aws_subnet.public[*].id

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  tag {
    key                 = "Name"
    value               = "Cocoplanner"
    propagate_at_launch = true
  }

  launch_template {
    id      = aws_launch_template.Cocoplanner.id
    version = "$Latest"
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