# main instance
resource "aws_instance" "web" {
  ami           = "${var.ami}"
  instance_type = "t2.micro"
  key_name        = aws_key_pair.main_key.key_name
  vpc_security_group_ids = [aws_security_group.alb.id]

  tags = {
    Name = "main-instance"
  }
}
# creeating key-pair
resource "aws_key_pair" "main_key" {
  key_name = "keykey"
  public_key = tls_private_key.rsa.public_key_openssh

}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "main_key" {
  content = tls_private_key.rsa.private_key_pem
  filename = "keykey"
  
}
resource "aws_eip" "ElasticIP" {
  instance = aws_instance.web.id  
}



###################################################
#Auto Scaling Group (ASG).
#An ASG takes care of a lot of tasks for you completely automatically, including launching
#a cluster of EC2 Instances, monitoring the health of each Instance, replacing failed
#Instances, and adjusting the size of the cluster in response to load.
###################################################

# configuring the launch configuration
resource "aws_launch_configuration" "example" {
  image_id        = "${var.ami}"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.alb.id]
  user_data       = file("userdata.sh") 

  # set create_before_destroy to true, Terraform will invert the order in which
  # it replaces resources, creating the replacement resource first to ensure continuity of service (zero downtime)
  lifecycle {
    create_before_destroy = true
  }
}

# Creating an autoscaling group
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids # getting subnets from variable 

  target_group_arns = [aws_lb_target_group.asg.arn] # integration between ASG and ALB so the target group knows 
                                                    # which EC2 instances to route traffic to since autoscaling 
                                                    #is initializing and terminating instances all the time.


  health_check_type = "ELB" # health check type is ELB (default is EC2)      

  min_size = 2
  max_size = 4
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

#Amazon’s Elastic Load Balancer (ELB)
#Gets single IP (DNS) of the load balancer instead of having multiple IPs for each instance.
# load balancer needs :  
#1- listener: Listens on a specific port (e.g., 80) and protocol (e.g., HTTP).
#2- listener rule: A listener rule defines how the listener should route requests to the target group.
#3- target group: A target group routes requests to the instances in the ASG.

resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]

}

# create a target group for ASG
#target group will health check your Instances by periodically sending an HTTP
#request to each Instance and will consider the Instance “healthy” only if the Instance
#returns a response that matches the configured matcher (e.g., you can configure a
#matcher to look for a 200 OK response)
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# define a listener for the above Application Load Balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn   
  } 
}
