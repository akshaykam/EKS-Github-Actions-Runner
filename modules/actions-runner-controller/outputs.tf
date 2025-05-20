output "runner_deployment_name" {
  value = kubernetes_manifest.runner_deployment.manifest.metadata.name
}