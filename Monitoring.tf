# CloudWatch Alarm for EKS CPU Utilization
resource "aws_cloudwatch_metric_alarm" "eks_cpu_utilization" {
  alarm_name          = "eks-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EKS pod CPU utilization"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = aws_eks_cluster.cocoplanner.name
  }
}

# CloudWatch Alarm for EKS Memory Usage
resource "aws_cloudwatch_metric_alarm" "eks_memory_usage" {
  alarm_name          = "eks-memory-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_memory_utilization"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EKS pod memory usage"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = aws_eks_cluster.cocoplanner.name
  }
}

# Create an SNS topic for CloudWatch alarms
resource "aws_sns_topic" "eks_alarms" {
  name = "eks-alarms-topic"
}

# Create an SNS topic subscription for email notifications
resource "aws_sns_topic_subscription" "eks_alarms_email" {
  topic_arn = aws_sns_topic.eks_alarms.arn
  protocol  = "email"
  endpoint  = "cocolancer.build@gmail.com"
} 
