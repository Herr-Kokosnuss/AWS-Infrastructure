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

  user_data = file("userdata.sh")

  # set create_before_destroy to true, Terraform will invert the order in which
  # it replaces resources, creating the replacement resource first
  lifecycle {
    create_before_destroy = true
  }
}

# Creating an autoscaling group
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids # getting subnets from variable 

  target_group_arns = [aws_lb_target_group.asg.arn] # integration between ASG and ALB so the target group knows 
  # which EC2 instances to route traffic to.


  health_check_type = "ELB" #a minimal health check that considers an
  # Instance unhealthy only if the AWS hypervisor says the VM is completely down or
  # unreachable. The "ELB" health check is more robust, because it instructs the ASG
  # to use the target group’s health check to determine whether an Instance is healthy
  # and to automatically replace Instances if the target group reports them as unhealthy.
  # That way, Instances will be replaced not only if they are completely down but also if,
  # for example, they’ve stopped serving requests because they ran out of memory or a
  # critical process crashed.        

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

# define a listener for the above Application Load Balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"
  # By default, return a simple 404 page.
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# create a target group for your ASG
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

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}