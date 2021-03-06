terraform {
  backend "s3" {
    bucket = "govuk-pay-terraform-state"
    key    = "staging"
    region = "eu-west-2"
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-2"
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
  alias   = "us"
}

provider "pass" {
  version       = "~> 1.2"
  store_dir     = "../../secrets"
  refresh_store = false
}

provider "pass" {
  version       = "~> 1.2"
  store_dir     = "../../../pay-low-pass"
  refresh_store = false
  alias         = "low-pass"
}

module "staging" {
  source = "../modules/aws"

  providers = {
    aws           = aws
    aws.us        = aws.us
    pass          = pass
    pass.low-pass = pass.low-pass
  }

  environment         = "staging"
  domain_name         = "gdspay.uk"
  paas_domain         = "cloudapps.digital"
}
