resource "opentelekomcloud_vpc_route_table_v1" "vpc_route_table_v1" {
  region      = var.region
  vpc_id      = var.vpc_id
  name        = var.name
  description = var.description
  subnets     = var.subnets

  dynamic "route" {
    for_each = var.legacy_inline_routes && var.route != null ? var.route : {}

    content {
      destination = route.value.destination
      type        = route.value.type
      nexthop     = route.value.nexthop
      description = route.value.description
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }
}

resource "opentelekomcloud_vpc_route_table_route_v1" "route" {
  for_each = !var.legacy_inline_routes && var.route != null ? var.route : {}

  region         = var.region
  vpc_id         = var.vpc_id
  route_table_id = opentelekomcloud_vpc_route_table_v1.vpc_route_table_v1.id
  destination    = each.value.destination
  type           = each.value.type
  nexthop        = each.value.nexthop
  description    = each.value.description
}
