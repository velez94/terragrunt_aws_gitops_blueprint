data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "current" {}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow access for specific OUs"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.current.id]
    }

    condition {
      test     = "StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = [
        for ou in var.sharing_ou_ids :
        "${data.aws_organizations_organization.current.id}/*/${ou}/*"
      ]
    }
  }
}
