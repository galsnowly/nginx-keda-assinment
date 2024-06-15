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
  source = "../../../terraform-modules/nginx"
}

include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

dependency "keda" {
  config_path = "../keda"
  mock_outputs = {
    namespace = "mock-namespace"
    queue_url = "mock-queue-url"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
}

inputs = {
  aws_region             = local.region
  keda_namespace         = dependency.keda.outputs.namespace
  keda_queue_url         = dependency.keda.outputs.queue_url
  aws_access_key_id      = get_env("AWS_ACCESS_KEY_ID", "")
  aws_secret_access_key  = get_env("AWS_SECRET_ACCESS_KEY", "")
}