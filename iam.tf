resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_iam_role.id
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "cloudwatch_kinesis_role" {
  name = "cloudwatch-kinesis-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_kinesis_policy" {
  name = "cloudwatch-kinesis-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "kinesis:PutRecord",
        Resource = aws_kinesis_stream.satellite_logs_stream.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_kinesis_attach" {
  role       = aws_iam_role.cloudwatch_kinesis_role.name
  policy_arn = aws_iam_policy.cloudwatch_kinesis_policy.arn
}

resource "aws_iam_policy" "kinesis_policy" {
  name        = "KinesisPolicy"
  path        = "/"
  description = "IAM policy for enabling full access to Kinesis streams"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kinesis:CreateStream",
          "kinesis:DeleteStream",
          "kinesis:DescribeStream",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListStreams",
          "kinesis:PutRecord",
          "kinesis:PutRecords",
          // Add any other Kinesis actions needed
        ],
        Resource = [
          "${aws_kinesis_stream.satellite_logs_stream.arn}",
          // You can also use "*" if you want this policy to apply to all streams
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData",
          // Add any other CloudWatch actions needed for monitoring Kinesis
        ],
        Resource = "*" // Adjust based on your CloudWatch resources and needs
      }
    ]
  })
}