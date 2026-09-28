<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
# OpenTelekomCloud VPC Route Table Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE)

This module creates an OpenTelekomCloud VPC route table, associates subnets and
manages individual routes. Routes are separate resources by default, with stable
addresses based on the keys in the `route` map.

# Features

- **Route Table Management**: Creates a named table within an existing VPC.
- **Subnet Associations**: Associates selected subnets with the table.
- **Individual Routes**: Adds, updates and deletes routes independently of the table.
- **Input Validation**: Checks names, descriptions, CIDR destinations and duplicate destinations.
- **Compatibility**: Retains an optional inline-route mode for existing consumers.
- **Timeout Control**: Supports create and delete timeouts for the table.

# Setup Requirements

Use Terraform `~> 1.12` and the OTC provider `>= 1.36.62`. The standalone route
resource is unavailable in the previously declared minimum version, `1.36.35`.

Supply credentials through the provider's supported environment variables, such
as `OS_USERNAME`, `OS_PASSWORD`, `OS_DOMAIN_NAME`, `OS_PROJECT_NAME` and `OS_REGION`.
The examples use the eu-de authentication endpoint; adjust `provider.tf` for your
region. Do not commit credentials.

# Example Usage

The [default example](examples/default/main.tf) creates a VPC and an empty custom
route table. The [full example](examples/full/main.tf) creates two VPCs, their
subnets, a same-project peering connection and route tables with reciprocal routes.
Both examples pin the public CloudAstro VPC and subnet dependencies where used:

```hcl
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
```
<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_opentelekomcloud"></a> [opentelekomcloud](#requirement\_opentelekomcloud) | >= 1.36.68 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_opentelekomcloud"></a> [opentelekomcloud](#provider\_opentelekomcloud) | >= 1.36.68 |

## Resources

| Name | Type |
|------|------|
| [opentelekomcloud_vpc_route_table_route_v1.route](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/vpc_route_table_route_v1) | resource |
| [opentelekomcloud_vpc_route_table_v1.vpc_route_table_v1](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/vpc_route_table_v1) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | * `name` - (Required, String) Specifies the route table name. The value is a string of no more than<br/>  64 characters that can contain letters, digits, underscores (\_), hyphens (-), and periods (.).<br/><br/>Example input:<pre>name = "rtb"</pre> | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | * `vpc_id` - (Required, String, ForceNew) Specifies the VPC ID for which a route table is to be added.<br/>  Changing this creates a new resource.<br/><br/>Example input:<pre>vpc_id = opentelekomcloud_vpc_v1.vpc_1.id</pre> | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | * `description` - (Optional, String) Specifies the supplementary information about the route table.<br/>  The value is a string of no more than 255 characters and cannot contain angle brackets (< or >).<br/><br/>Example input:<pre>description = "description"</pre> | `string` | `null` | no |
| <a name="input_legacy_inline_routes"></a> [legacy\_inline\_routes](#input\_legacy\_inline\_routes) | Compatibility option for existing inline-route consumers. Leave false for new deployments. Switching modes on a populated table requires an explicit state migration; do not toggle during a normal apply. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | * `region` - (Optional, String, ForceNew) The region in which to create the vpc route table.<br/>  If omitted, the provider-level region will be used. Changing this creates a new resource.<br/><br/>Example input:<pre>region = "eu-de"</pre> | `string` | `null` | no |
| <a name="input_route"></a> [route](#input\_route) | * `route` - (Optional, Map) Specifies individual route entries to add to the route table<br/>  using `opentelekomcloud_vpc_route_table_route_v1`. This manages routes independently of the<br/>  route table lifecycle without replacing the whole table.<br/>  * `destination` - (Required, String) Specifies the destination address in CIDR notation.<br/>  * `nexthop` - (Required, String) Next-hop resource ID for the selected route type;<br/>    use an IP address for `vip`.<br/>  * `type` - (Required, String) Specifies the route type. Valid values: `ecs`, `eni`, `vip`,<br/>    `nat`, `peering`, `vpn`, `dc`, `egw`, `er`, `subeni` and `local`.<br/>    Availability and next-hop requirements depend on the OTC API.<br/>  * `description` - (Optional, String) Specifies a description for the route.<br/><br/>Example input:<pre>route = {<br/>  route_01 = {<br/>    destination = "0.0.0.0/0"<br/>    type        = "er"<br/>    nexthop     = opentelekomcloud_er_instance_v3.example.id<br/>    description = "er route"<br/>  }<br/>}</pre> | <pre>map(object({<br/>    destination = string<br/>    nexthop     = string<br/>    type        = string<br/>    description = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | * `subnets` - (Optional, List) Specifies an array of one or more subnets associating with the route table.<br/><br/>Example input:<pre>subnets = [<br/>  opentelekomcloud_vpc_subnet_v1.first.id,<br/>  opentelekomcloud_vpc_subnet_v1.second.id,<br/>]</pre> | `set(string)` | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | * `timeouts` - (Optional) A timeouts block. This allows you to specify timeouts for create and delete operations.<br/>  * `create` - (Optional) The time to wait for the route table to be created.<br/>  * `delete` - (Optional) The time to wait for the route table to be deleted.<br/><br/>Example input:<pre>timeouts = {<br/>  create = "1m"<br/>  delete = "1m"<br/>}</pre> | <pre>object({<br/>    create = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_route_table"></a> [vpc\_route\_table](#output\_vpc\_route\_table) | The route table resource, including its ID, name, VPC and subnet associations.<br/><br/>Example output:<pre>hcl<br/>output "route_table_id" {<br/>  value = module.rtb.vpc_route_table.id<br/>}</pre> |

## Modules

No modules.

## 🌐 Additional Information

- Use `module.rtb.vpc_route_table.id` to reference the table.
- `subnets` takes OTC VPC subnet resource IDs (`module.subnet.vpc_subnet.id`), not the OpenStack subnet IDs exposed as `.subnet_id`. All associated subnets must belong to the table's VPC.
- The `route` map defaults to no managed routes. Each key identifies a separate `opentelekomcloud_vpc_route_table_route_v1` resource unless `legacy_inline_routes` is enabled.
- The table output is the provider's table snapshot. With separately managed routes, it is not an ordering dependency for route completion and may reflect the preceding refresh.
- The full example uses a provider resource for peering so it does not depend on an unpublished module or a sibling checkout.

## 📚 Resources

- [Terraform VPC Route Table Resource](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/vpc_route_table_v1)
- [Terraform Individual Route Resource](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/vpc_route_table_route_v1)
- [Terraform OpenTelekomCloud Provider](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs)
- [Contributing](CONTRIBUTING.md)

## ⚠️ Notes

- Keep route map keys stable. Renaming a key changes its Terraform resource address.
- Destinations must be unique within the table and satisfy OTC restrictions for the local VPC. Overlapping remote CIDRs are not categorically rejected by this module; OTC routing rules still apply.
- A `vip` next hop is an IP address. Other route types generally reference a resource ID; consult the provider documentation for the selected type.
- Security groups, network ACLs and guest routing must allow the intended traffic. The example provisions no workloads or traffic validation.
- Keep `legacy_inline_routes = false` for new deployments. Do not switch modes on a populated table without planning the state migration, and do not manage the same routes inline and through separate resources.
- Resource addresses and the `vpc_route_table` output are unchanged. No migration blocks are added.
- The `timeouts` input applies to the route table, not to the individual route resources.
- Generate this README with `terraform-docs .`; edit `_header.md`, `_footer.md` and Terraform descriptions. GitHub workflows assume this directory is the root of a standalone repository.
- Release Please reads `release-please-config.json` and `.release-please-manifest.json`, including the configured initial version `1.0.0`. Subsequent release PRs are based on conventional commits. Do not manually tag a version that an outstanding release PR is meant to create.
- The intended public module address is `CloudAstro/vpc-route-table/opentelekomcloud`. This preparation does not publish a release.

## 🧾 License

This module is released under the **Apache 2.0 License**, as declared in its existing
documentation. See [LICENSE](LICENSE) for the full text.
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->