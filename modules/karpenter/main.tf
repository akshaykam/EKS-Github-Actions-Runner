resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  namespace  = "karpenter"
  create_namespace = true

  values = [
    file("${path.module}/../../values/karpenter.yaml")
  ]

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = "eks-${var.cluster_name}-karpenter-instance-profile"
  }
}