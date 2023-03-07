# External DNS
data "aws_iam_policy_document" "external_dns_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

# The role to be assumed by the service account through oidc
resource "aws_iam_role" "external_dns" {
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role_policy.json
  name               = "external-dns"
}

# The policy attached to the role to be assumed
resource "aws_iam_policy" "external_dns_policy" {
  policy = file("./external-dns-policy.json")
  name   = "MyProfileExternalDNSAccessPolicy"
}

# Attaching the policy
resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}

# Create external DNS objects
data "kubectl_file_documents" "external-dns" {
  content = file("./external-dns.yaml")
}

resource "kubectl_manifest" "external-dns" {
  depends_on = [kubectl_manifest.argocd_namespace]
  count      = length(data.kubectl_file_documents.external-dns.documents)
  yaml_body  = element(data.kubectl_file_documents.external-dns.documents, count.index)
}
