module "eks" { 
source = "./modules/eks"
cluster_name = "eks-cluster-AK" 
cluster_version = "1.32"
vpc_id = var.vpc_id 
subnet_ids = var.subnet_ids 
security_group_ids = var.security_group_ids 
node_group_min_size = 1 
node_group_max_size = 3 
node_group_desired_size = 2 
node_group_instance_types = ["t3.medium"] 
}

module "karpenter" { 
source = "./modules/karpenter"
cluster_name = module.eks.cluster_id 
cluster_endpoint = module.eks.cluster_endpoint 
depends_on = [module.eks] 
}

module "actions_runner_controller" { 
source = "./modules/actions-runner-controller"
github_token = var.github_token 
github_repository = var.github_repository 
cluster_endpoint = module.eks.cluster_endpoint 
cluster_ca_certificate = module.eks.cluster_ca_certificate 
cluster_name = module.eks.cluster_id 
depends_on = [module.karpenter] 
}