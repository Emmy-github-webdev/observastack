terraform {
  required_version = ">= 1.14.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "observastack"
      Environment = "dev"
      ManagedBy   = "Terraform"
      Repository  = "Emmy-github-webdev/observastack"
      Owner       = "ObservaStack"
    }
  }
}
