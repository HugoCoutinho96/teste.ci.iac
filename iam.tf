resource "aws_iam_openid_connect_provider" "oidc_git" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "74f3a68f16524f15424927704c9506f55a9316bd"
  ]

  tags = {
    Iac = true
  }
}

resource "aws_iam_role" "tf_role" {
  name = "tf-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "arn:aws:iam::484109133616:oidc-provider/token.actions.githubusercontent.com"
        },
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : [
              "sts.amazonaws.com"
            ],
            "token.actions.githubusercontent.com:sub" : [
              "repo:HugoCoutinho96/teste.ci.iac:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Iac = true
  }
}

resource "aws_iam_role_policy" "tf_role_policy" {
  name = "tf-role-policy"
  role = aws_iam_role.tf_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowECR"
        Action   = "ecr:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid      = "AllowIAM"
        Action   = "iam:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "AllowS3AccessToObjects"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::projeto-iac-state/state/*"
      },
      {
        Sid = "AllowS3BucketMetadata"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketAcl",
          "s3:GetBucketCORS",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation",
          "s3:GetBucketTagging",
          "s3:GetBucketLogging",
          "s3:GetBucketPolicy",
          "s3:GetBucketPolicyStatus",
          "s3:GetBucketWebsite",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetAccelerateConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketReplication",
          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:GetBucketObjectLockConfiguration", // 🆕 aqui
          "s3:PutBucketAcl",
          "s3:PutBucketCORS",
          "s3:PutBucketVersioning",
          "s3:PutBucketLogging",
          "s3:PutBucketPolicy",
          "s3:PutBucketTagging",
          "s3:PutBucketWebsite",
          "s3:PutBucketRequestPayment",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutEncryptionConfiguration",
          "s3:PutBucketReplication",
          "s3:PutLifecycleConfiguration",
          "s3:DeleteBucketPolicy",
          "s3:DeleteBucketWebsite",
          "s3:DeleteLifecycleConfiguration"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::projeto-iac-state"
      }
    ]
  })
}

resource "aws_iam_role" "app-runner-role" {
  name = "app-runner-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "Statement1",
        Effect : "Allow",
        Principal : {
          Service : "build.apprunner.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Iac = true
  }
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.app-runner-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "arn:aws:iam::484109133616:oidc-provider/token.actions.githubusercontent.com"
        },
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : [
              "sts.amazonaws.com"
            ],
            "token.actions.githubusercontent.com:sub" : [
              "repo:HugoCoutinho96/teste.ci.api:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecr-upload" {
  name = "ecr-upload-policy"
  role = aws_iam_role.ecr-role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "Statement1"
        Action   = "apprunner:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Statement2"
        Action = [
          "iam:PassRole",
          "iam:CreateServiceLinkedRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Statement3"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:UploadLayerPart",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}