resource "kubectl_manifest" "argocd_namespace" {
  yaml_body = <<-EOF
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
EOF
}

data "kubectl_file_documents" "argocd" {
  content = file("./argocd.yaml")
}

resource "kubectl_manifest" "argocd" {
  depends_on         = [kubectl_manifest.argocd_namespace]
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
}