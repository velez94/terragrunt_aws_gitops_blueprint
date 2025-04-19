
/*
* # Module for terraform-aws-irsa-eks-hub deployment
*
* Terraform stack to provision a custom terraform-aws-irsa-eks-hub
*
*/
module "irsa_eks_hub" {
source = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "5.55.0"
  role_name = var.role_name
  cluster_service_accounts =  var.cluster_service_accounts
  role_policy_arns = {
    hub = module.policy_hub.arn
  }
  force_detach_policies = true
  tags = var.tags
}

module "policy_hub"{
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.55.0"
  name = "${var.role_name }-policy"
  path = "/control_plane/"
  description = "Policy to allow EKS Hub to manage resources on cluster"
  policy = data.aws_iam_policy_document.policy_hub.json
}

data "aws_iam_policy_document" "policy_hub" {
  statement {
    sid       = "EksHub"
    effect    = "Allow"
    resources = var.spoke_roles_arn
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"

    ]
  }
}
#resource "aws_iam_role_policy_attachment" "this" {
#  for_each = { for k, v in var.role_policy_arns : k => v if var.create_role }
#
#  role       = aws_iam_role.this[0].name
#  policy_arn = each.value
#}