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
