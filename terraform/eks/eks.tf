module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  endpoint_public_access  = true
  endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

  addons = {
    vpc-cni = {
      before_compute = true
    }

    kube-proxy = {}

    coredns = {}
  }

  eks_managed_node_groups = {
    general = {
      name = "ob-dev-general"

      iam_role_name            = "ob-dev-eks-node-role"
      iam_role_use_name_prefix = false

      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      disk_size = 20

      labels = {
        role        = "general"
        environment = var.environment
      }
    }
  }

  tags = {
    Name = var.cluster_name
  }
}