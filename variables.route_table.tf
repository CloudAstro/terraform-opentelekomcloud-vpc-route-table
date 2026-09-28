variable "region" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `region` - (Optional, String, ForceNew) The region in which to create the vpc route table.
  If omitted, the provider-level region will be used. Changing this creates a new resource.

Example input:
```
region = "eu-de"
```
DESCRIPTION
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = <<DESCRIPTION
* `vpc_id` - (Required, String, ForceNew) Specifies the VPC ID for which a route table is to be added.
  Changing this creates a new resource.

Example input:
```
vpc_id = opentelekomcloud_vpc_v1.vpc_1.id
```
DESCRIPTION

  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "name" {
  type        = string
  nullable    = false
  description = <<DESCRIPTION
* `name` - (Required, String) Specifies the route table name. The value is a string of no more than
  64 characters that can contain letters, digits, underscores (_), hyphens (-), and periods (.).

Example input:
```
name = "rtb"
```
DESCRIPTION

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]{1,64}$", var.name))
    error_message = "name must contain 1 to 64 letters, digits, underscores, hyphens or periods."
  }
}

variable "description" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `description` - (Optional, String) Specifies the supplementary information about the route table.
  The value is a string of no more than 255 characters and cannot contain angle brackets (< or >).

Example input:
```
description = "description"
```
DESCRIPTION

  validation {
    condition     = var.description == null ? true : can(regex("^[^<>]{0,255}$", var.description))
    error_message = "description must be at most 255 characters and must not contain angle brackets."
  }
}

variable "subnets" {
  type        = set(string)
  default     = null
  description = <<DESCRIPTION
* `subnets` - (Optional, List) Specifies an array of one or more subnets associating with the route table.

Example input:
```
subnets = [
  opentelekomcloud_vpc_subnet_v1.first.id,
  opentelekomcloud_vpc_subnet_v1.second.id,
]
```
DESCRIPTION
}

variable "route" {
  type = map(object({
    destination = string
    nexthop     = string
    type        = string
    description = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
* `route` - (Optional, Map) Specifies individual route entries to add to the route table
  using `opentelekomcloud_vpc_route_table_route_v1`. This manages routes independently of the
  route table lifecycle without replacing the whole table.
  * `destination` - (Required, String) Specifies the destination address in CIDR notation.
  * `nexthop` - (Required, String) Next-hop resource ID for the selected route type;
    use an IP address for `vip`.
  * `type` - (Required, String) Specifies the route type. Valid values: `ecs`, `eni`, `vip`,
    `nat`, `peering`, `vpn`, `dc`, `egw`, `er`, `subeni` and `local`.
    Availability and next-hop requirements depend on the OTC API.
  * `description` - (Optional, String) Specifies a description for the route.

Example input:
```
route = {
  route_01 = {
    destination = "0.0.0.0/0"
    type        = "er"
    nexthop     = opentelekomcloud_er_instance_v3.example.id
    description = "er route"
  }
}
```
DESCRIPTION

  validation {
    condition = var.route == null ? true : alltrue([
      for entry in values(var.route) : try(
        can(cidrhost(entry.destination, 0)) && length(trimspace(entry.nexthop)) > 0 && length(trimspace(entry.type)) > 0,
        false
      )
    ])
    error_message = "Each route must have a valid CIDR destination and non-empty type and nexthop."
  }

  validation {
    condition = var.route == null ? true : length(distinct([
      for entry in values(var.route) : try("${cidrhost(entry.destination, 0)}/${split("/", entry.destination)[1]}", "")
    ])) == length(var.route)
    error_message = "Route destinations must be unique within the table."
  }
}

variable "legacy_inline_routes" {
  type        = bool
  default     = false
  nullable    = false
  description = "Compatibility option for existing inline-route consumers. Leave false for new deployments. Switching modes on a populated table requires an explicit state migration; do not toggle during a normal apply."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
* `timeouts` - (Optional) A timeouts block. This allows you to specify timeouts for create and delete operations.
  * `create` - (Optional) The time to wait for the route table to be created.
  * `delete` - (Optional) The time to wait for the route table to be deleted.

Example input:
```
timeouts = {
  create = "1m"
  delete = "1m"
}
```
DESCRIPTION
}
