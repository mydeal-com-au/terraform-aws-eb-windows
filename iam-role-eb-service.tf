resource "aws_iam_role" "eb_service" {
  name_prefix = "eb-service-role-"
  path        = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eb_enhanced_health" {
  role       = aws_iam_role.eb_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "eb_service" {
  role       = aws_iam_role.eb_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

data "aws_iam_policy_document" "eb_ssm_parameters" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "eb_ssm_parameters" {
  name_prefix = "eb-ssm-parameters-${var.environment}-${var.name}-"
  policy      = data.aws_iam_policy_document.eb_ssm_parameters.json
  role       = aws_iam_role.eb_service.name
}
