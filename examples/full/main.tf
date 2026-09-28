module "vpc_01" {
  source  = "CloudAstro/vpc/opentelekomcloud"
  version = "1.1.1"

  name = "vpc-01"
  cidr = "192.168.0.0/16"
}

module "vpc_02" {
  source  = "CloudAstro/vpc/opentelekomcloud"
  version = "1.1.1"

  name = "vpc-02"
  cidr = "172.16.0.0/16"
}

module "subnet_01" {
  source  = "CloudAstro/vpc-subnet/opentelekomcloud"
  version = "1.1.1"

  name       = "subnet-01"
  cidr       = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"
  vpc_id     = module.vpc_01.vpc_v1.id
}

module "subnet_02" {
  source  = "CloudAstro/vpc-subnet/opentelekomcloud"
  version = "1.1.1"

  name       = "subnet-02"
  cidr       = "172.16.0.0/24"
  gateway_ip = "172.16.0.1"
  vpc_id     = module.vpc_02.vpc_v1.id
}

resource "opentelekomcloud_vpc_peering_connection_v2" "peering" {
  name        = "route-table-example"
  vpc_id      = module.vpc_01.vpc_v1.id
  peer_vpc_id = module.vpc_02.vpc_v1.id
}

module "rtb" {
  source = "../.."

  name        = "rtb-vpc-01"
  vpc_id      = module.vpc_01.vpc_v1.id
  description = "Routes from VPC 01 to VPC 02"
  subnets     = [module.subnet_01.vpc_subnet.id]

  route = {
    to_vpc_02 = {
      destination = module.vpc_02.vpc_v1.cidr
      type        = "peering"
      nexthop     = opentelekomcloud_vpc_peering_connection_v2.peering.id
      description = "Peer VPC 02"
    }
  }

  timeouts = {
    create = "10m"
    delete = "10m"
  }
}

module "peer_rtb" {
  source = "../.."

  name        = "rtb-vpc-02"
  vpc_id      = module.vpc_02.vpc_v1.id
  description = "Return route from VPC 02 to VPC 01"
  subnets     = [module.subnet_02.vpc_subnet.id]

  route = {
    to_vpc_01 = {
      destination = module.vpc_01.vpc_v1.cidr
      type        = "peering"
      nexthop     = opentelekomcloud_vpc_peering_connection_v2.peering.id
      description = "Peer VPC 01"
    }
  }
}
