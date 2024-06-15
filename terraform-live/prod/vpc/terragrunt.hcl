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
  source = "../../../terraform-modules/vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("terragrunt.hcl")
}

inputs = {
  aws_region = local.region
  cidr       = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  tags = merge(
    local.tags,
    {
      Name = "carbyne-vpc"
    }
  )
}
