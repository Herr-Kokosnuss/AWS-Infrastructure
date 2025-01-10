# CloudWatch Alarm for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "asg-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = [aws_sns_topic.asg_alarms.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
}

# CloudWatch Alarm for EFS Disk Usage
resource "aws_cloudwatch_metric_alarm" "efs_disk_usage" {
  alarm_name          = "efs-disk-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "PercentIOLimit"
  namespace           = "AWS/EFS"
  period              = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description   = "This metric monitors EFS disk usage"
  alarm_actions       = [aws_sns_topic.asg_alarms.arn]

  dimensions = {
    FileSystemId = aws_efs_file_system.example.id
  }
}

# CloudWatch Alarm for Memory Usage
resource "aws_cloudwatch_metric_alarm" "memory_usage" {
  alarm_name          = "asg-memory-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CustomMetrics"
  period              = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description   = "This metric monitors EC2 memory usage"
  alarm_actions       = [aws_sns_topic.asg_alarms.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
}

# Create an SNS topic for CloudWatch alarms
resource "aws_sns_topic" "asg_alarms" {
  name = "asg-alarms-topic"
}

# Create an SNS topic subscription for email notifications
resource "aws_sns_topic_subscription" "asg_alarms_email" {
  topic_arn = aws_sns_topic.asg_alarms.arn
  protocol  = "email"
  endpoint  = "ahmed.alsaeedi7890@gmail.com"
} 