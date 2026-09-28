module "vpc" {
  source  = "CloudAstro/vpc/opentelekomcloud"
  version = "1.1.1"

  name = "vpc-route-table-example"
  cidr = "10.10.0.0/24"
}

module "rtb" {
  source = "../.."

  name   = "rtb-example"
  vpc_id = module.vpc.vpc_v1.id
}
