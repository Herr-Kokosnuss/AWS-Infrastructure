# Create IAM user for grafana
resource "aws_iam_user" "grafana_cloudwatch" {
  name = "grafana_cloudwatch"
  path = "/system/"

  tags = {
    Description = "IAM user for Grafana CloudWatch integration"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Update the IAM user policy for Grafana CloudWatch
resource "aws_iam_policy" "grafana_cloudwatch_policy" {
  name        = "grafana_cloudwatch_policy"
  path        = "/"
  description = "IAM policy for Grafana CloudWatch integration"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData",
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents",
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "grafana_cloudwatch_policy_attach" {
  user       = aws_iam_user.grafana_cloudwatch.name
  policy_arn = aws_iam_policy.grafana_cloudwatch_policy.arn
}

# Create access key for the Grafana user
resource "aws_iam_access_key" "grafana_cloudwatch" {
  user = aws_iam_user.grafana_cloudwatch.name

  lifecycle {
    create_before_destroy = true
  }
}
