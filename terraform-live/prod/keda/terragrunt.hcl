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
  source = "../../../terraform-modules/keda"
}

include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  aws_region      = local.region
  environment     = "dev"
}