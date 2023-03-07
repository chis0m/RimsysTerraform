# Allows EKS Service Account(SA) "aws-load-balancer-controller" to assume the role
# The SA is part of K8 RBAC which is authenticated against IAM through oidc
# This is why the assume policy is using web identity type

# data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
#     }

#     principals {
#       identifiers = [module.eks.oidc_provider_arn]
#       type        = "Federated"
#     }
#   }
# }

# # The role to be assumed by the service account through oidc
# resource "aws_iam_role" "aws_load_balancer_controller" {
#   assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
#   name               = "MyProfileAWSLoadBalancerController"
# }

# # The policy attached to the role to be assumed
# resource "aws_iam_policy" "aws_load_balancer_controller" {
#   policy = file("./AWSLoadBalancerController.json")
#   name   = "AWSLoadBalancerController"
# }

# # Attaching the policy
# resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
#   role       = aws_iam_role.aws_load_balancer_controller.name
#   policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
# }

# output "aws_load_balancer_controller_role_arn" {
#   value = aws_iam_role.aws_load_balancer_controller.arn
# }


# resource "helm_release" "aws-load-balancer-controller-for-ingress" {
#   name = "aws-load-balancer-controller"

#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.4.8"

#   set {
#     name  = "clusterName"
#     value = module.eks.cluster_id
#   }

#   set {
#     name  = "image.tag"
#     value = "v2.4.7"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.aws_load_balancer_controller.arn
#   }

#   depends_on = [
#     #aws_eks_node_group.private-nodes,
#     aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
#   ]
# }