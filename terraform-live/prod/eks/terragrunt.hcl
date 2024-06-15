locals {
  # Automatically load environment-level variables
  region_vars          = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  region     = local.region_vars.locals.aws_region
  env        = local.environment_vars.locals.environment

  tags = {
    "Managed-by" : "terraform",
    "Environment" : local.env,
    "Region" : local.region
  }
}

terraform {
  source = "../../../terraform-modules/eks"
}

dependency "vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_id          = "fake-vpc-id"
    private_subnets = ["10.0.0.0/16"]
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("terragrunt.hcl")
}

inputs = {

  aws_region      = local.region

  cluster_name    = "carbyne-${local.env}-eks"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  vpc_id          = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.private_subnet_ids

  eks_managed_node_groups = {
    "carbyne-${local.env}-ng" = {
      ami_type         = "AL2_x86_64" // Can't make use of AL2_ARM_64 beacuse of the Keda
      desired_capacity = 2
      min_size = 2
      max_size = 3

      capacity_type = "ON_DEMAND"
      instance_types = ["t3a.small","t3a.medium"]

      tags = merge(
        local.tags,
        {
          CustomerName = "Carbyne",
          Name = "carbyne-eks-cluster"
        }
      )

    }
  }

  tags = merge(local.tags, {})

}