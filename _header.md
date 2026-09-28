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
