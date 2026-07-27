output "vpc_id" {
  description = "ID of the VPC used by the EKS cluster."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by EKS worker nodes and load balancers."
  value       = module.vpc.public_subnets
}

output "availability_zones" {
  description = "Availability Zones used by the VPC."
  value       = local.availability_zones
}
output "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "API server endpoint for the Amazon EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version used by the EKS cluster."
  value       = module.eks.cluster_version
}

output "configure_kubectl_command" {
  description = "Command used to configure kubectl for this cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name} --profile ${var.aws_profile}"
}