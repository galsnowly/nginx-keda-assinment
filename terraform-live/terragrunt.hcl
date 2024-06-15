locals {
  common_tags = {
    Project = "Carbyne"
  }
}

inputs = {
  common_tags = local.common_tags
}