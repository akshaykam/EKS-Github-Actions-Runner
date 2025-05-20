provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}



resource "helm_release" "actions_runner_controller" {
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  namespace  = "actions-runner-system"
  create_namespace = true

  values = [
    file("${path.module}/../../values/actions-runner-controller.yaml")
  ]

  set {
    name  = "githubWebhookServer.enabled"
    value = "false"
  }
}

resource "kubernetes_secret" "controller_manager" {
  metadata {
    name      = "controller-manager"
    namespace = "actions-runner-system"
  }

  data = {
    github_token = var.github_token
  }

  depends_on = [helm_release.actions_runner_controller]
}

resource "kubernetes_manifest" "runner_deployment" {
  manifest = {
    apiVersion = "actions.summerwind.dev/v1alpha1"
    kind       = "RunnerDeployment"
    metadata = {
      name      = "eks-runner"
      namespace = "actions-runner-system"
    }
    spec = {
      template = {
        spec = {
          repository = var.github_repository
          labels = ["self-hosted", "eks"]
          nodeSelector = {
            "github-runner" = "true"
          }
          tolerations = [
            {
              key      = "github-runner"
              operator = "Equal"
              value    = "true"
              effect   = "NoSchedule"
            }
          ]
        }
      }
    }
  }

  depends_on = [kubernetes_secret.controller_manager]
}