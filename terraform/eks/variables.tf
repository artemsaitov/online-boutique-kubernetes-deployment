variable "aws_region" {
  description = "AWS region where the EKS infrastructure will be created."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Local AWS CLI profile Terraform should use."
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
  default     = "online-boutique"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Amazon EKS cluster name."
  type        = string
  default     = "online-boutique-dev"
}

variable "kubernetes_version" {
  description = "Kubernetes version used by the EKS control plane."
  type        = string
  default     = "1.35"
}

variable "vpc_cidr" {
  description = "CIDR range used by the EKS VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "node_instance_types" {
  description = "EC2 instance types used by the EKS managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 2
}