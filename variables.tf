variable "github_token" {
  description = "GitHub Personal Access Token for Actions Runner Controller"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
}

variable "github_repository" {
  description = "GitHub repository for the Actions Runner (e.g., your-org/your-repo)"
  type        = string
}