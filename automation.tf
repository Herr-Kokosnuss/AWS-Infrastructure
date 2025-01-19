# GitHub Actions Policy (includes both ECR and ASG permissions)
resource "aws_iam_policy" "github_actions_policy" {
  name        = "github-actions-policy"
  description = "Policy for GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "autoscaling:StartInstanceRefresh"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create the IAM user
resource "aws_iam_user" "github_actions_user" {
  name = "github-actions-user"
}

# Attach policy to the user
resource "aws_iam_user_policy_attachment" "github_actions_user_policy" {
  user       = aws_iam_user.github_actions_user.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

# Create access key
resource "aws_iam_access_key" "github_actions_user" {
  user = aws_iam_user.github_actions_user.name
}

