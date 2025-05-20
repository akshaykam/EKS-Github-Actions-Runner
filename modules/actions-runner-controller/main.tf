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

  depends_on = [module.karpenter]
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