output "vpc_route_table" {
  value       = opentelekomcloud_vpc_route_table_v1.vpc_route_table_v1
  description = <<DESCRIPTION
The route table resource, including its ID, name, VPC and subnet associations.

Example output:
```hcl
output "route_table_id" {
  value = module.rtb.vpc_route_table.id
}
```
DESCRIPTION
}
