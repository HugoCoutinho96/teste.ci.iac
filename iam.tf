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
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Principal": {
                "Federated": "arn:aws:iam::484109133616:oidc-provider/token.actions.githubusercontent.com"
            },
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": [
                        "sts.amazonaws.com"
                    ],
                    "token.actions.githubusercontent.com:sub": [
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

resource "aws_iam_role" "app-runner-role" {
  name = "app-runner-role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "Statement1",
        Effect: "Allow",
        Principal: {
          Service: "build.apprunner.amazonaws.com"
        },
        Action: "sts:AssumeRole"
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
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Principal": {
                "Federated": "arn:aws:iam::484109133616:oidc-provider/token.actions.githubusercontent.com"
            },
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": [
                        "sts.amazonaws.com"
                    ],
                    "token.actions.githubusercontent.com:sub": [
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
          Sid      = "Statement2"
          Action   = [
            "iam:PassRole",
            "iam:CreateServiceLinkedRole"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Sid      = "Statement3"
          Action   = [
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