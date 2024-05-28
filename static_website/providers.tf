provider "aws" {
  # The provider will use the profile if use_aws_profile is true; otherwise, it will expect access and secret keys.
  profile    = var.use_aws_profile ? var.profile : null
  access_key = var.use_aws_profile ? null : var.aws_access_key_id
  secret_key = var.use_aws_profile ? null : var.aws_secret_access_key
  region     = var.region_master
  alias      = "abd"

  # Assuming that region_master is also a variable declared in your configuration.
}