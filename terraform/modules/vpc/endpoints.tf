############################
# VPC Endpoint Security Group
############################

resource "aws_security_group" "vpc_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  name        = "${local.name_prefix}-vpc-endpoints"
  description = "Security group for ObservaStack VPC interface endpoints"
  vpc_id      = aws_vpc.observastack_vpc.id

  ingress {
    description = "HTTPS from VPC"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "HTTPS to AWS services"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.name_prefix}-vpc-endpoints"
      Component = "vpc-endpoints"
    }
  )
}


############################
# S3 Gateway Endpoint
############################

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.observastack_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    for rt in aws_route_table.private_rt : rt.id
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowS3ReadAccess"
        Effect = "Allow"

        Principal = "*"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]

        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.name_prefix}-s3-endpoint"
      Component = "vpc-endpoint"
      Service   = "s3"
    }
  )
}


############################
# ECR API Interface Endpoint
############################

resource "aws_vpc_endpoint" "ecr_api" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.observastack_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    for subnet in aws_subnet.priv_subnet : subnet.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints[0].id
  ]

  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowECRAPI"
        Effect = "Allow"

        Principal = "*"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer"
        ]

        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.name_prefix}-ecr-api-endpoint"
      Component = "vpc-endpoint"
      Service   = "ecr-api"
    }
  )
}


############################
# ECR DKR Interface Endpoint
############################

resource "aws_vpc_endpoint" "ecr_dkr" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.observastack_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    for subnet in aws_subnet.priv_subnet : subnet.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints[0].id
  ]

  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowECRDKR"
        Effect = "Allow"

        Principal = "*"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]

        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.name_prefix}-ecr-dkr-endpoint"
      Component = "vpc-endpoint"
      Service   = "ecr-dkr"
    }
  )
}


############################
# CloudWatch Logs Interface Endpoint
############################

resource "aws_vpc_endpoint" "logs" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.observastack_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    for subnet in aws_subnet.priv_subnet : subnet.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints[0].id
  ]

  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"

        Principal = "*"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.name_prefix}-logs-endpoint"
      Component = "vpc-endpoint"
      Service   = "cloudwatch-logs"
    }
  )
}


############################
# STS Interface Endpoint
############################

resource "aws_vpc_endpoint" "sts" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.observastack_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.sts"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    for subnet in aws_subnet.priv_subnet : subnet.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints[0].id
  ]

  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowSTS"
        Effect = "Allow"

        Principal = "*"

        Action = [
          "sts:GetCallerIdentity",
          "sts:AssumeRole",
          "sts:AssumeRoleWithWebIdentity"
        ]

        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.name_prefix}-sts-endpoint"
      Component = "vpc-endpoint"
      Service   = "sts"
    }
  )
}