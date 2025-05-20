variable "github_token" {
  description = "GitHub Personal Access Token for Actions Runner Controller"
  type        = string
  sensitive   = true
}

variable "github_repository" {
  description = "GitHub repository for the Actions Runner (e.g., your-org/your-repo)"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}