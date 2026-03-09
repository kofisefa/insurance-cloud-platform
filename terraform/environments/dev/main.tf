provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = "insurance-dev-vpc"
  vpc_cidr = "10.0.0.0/16"

  public_subnet_1 = "10.0.1.0/24"
  public_subnet_2 = "10.0.2.0/24"

  az1 = "us-east-2a"
  az2 = "us-east-2b"
}