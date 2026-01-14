locals {
  issuer           = "https://token.actions.githubusercontent.com"
  sub_all_branches = "repo:${var.github_owner}/${github_repository.default.name}:ref:refs/heads/*"
  sub_main_branch  = "repo:${var.github_owner}/${github_repository.default.name}:ref:refs/heads/main"
  sub_pull_request = "repo:${var.github_owner}/${github_repository.default.name}:pull_request"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  client_id_list = ["sts.amazonaws.com"]
  url            = local.issuer
}

data "aws_iam_policy_document" "apply" {
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
      values   = [local.sub_main_branch]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "plan" {
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
      values   = [local.sub_all_branches, local.sub_pull_request]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "apply" {
  name_prefix        = "terraform-github-apply"
  assume_role_policy = data.aws_iam_policy_document.apply.json
}

resource "aws_iam_role_policy_attachment" "apply" {
  role       = aws_iam_role.apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "plan" {
  name_prefix        = "terraform-github-plan"
  assume_role_policy = data.aws_iam_policy_document.plan.json
}

resource "aws_iam_role_policy_attachment" "read_only_access" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
