locals {
  issuer   = "https://token.actions.githubusercontent.com"
  sub_all  = "repo:${var.github_owner}/${github_repository.default.name}:ref:refs/heads/*"
  sub_main = "repo:${var.github_owner}/${github_repository.default.name}:ref:refs/heads/main"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  client_id_list = ["sts.amazonaws.com"]
  url            = local.issuer
}

data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn,
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.sub_main]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "all" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn,
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.sub_all]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "main" {
  name_prefix        = "terraform-github-main"
  assume_role_policy = data.aws_iam_policy_document.main.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "all" {
  name_prefix        = "terraform-github-all"
  assume_role_policy = data.aws_iam_policy_document.all.json
}

resource "aws_iam_role_policy_attachment" "read_only_access" {
  role       = aws_iam_role.all.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
