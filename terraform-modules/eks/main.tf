
provider "aws" {
  region = var.aws_region
}

module "eks" {

  source                       = "terraform-aws-modules/eks/aws"

  cluster_name                 = var.cluster_name
  cluster_version              = var.cluster_version

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                       = var.vpc_id
  subnet_ids                   = var.private_subnets

  cluster_enabled_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true

  create_iam_role              = true

  eks_managed_node_groups = var.eks_managed_node_groups

  tags = var.tags

}