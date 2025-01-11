output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "az_available" {
#   value = module.vpc.availability_zones
# }

# output "default_vpc_id" {
#   value = module.vpc.default_vpc_id
# }

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "db_subnet_ids" {
  value = module.vpc.db_subnet_ids
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_id
}

output "db_route_table_id" {
  value = module.vpc.db_route_table_id
}
