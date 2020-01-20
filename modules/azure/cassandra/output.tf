output "cassandra_provision_ids" {
  value = module.cassandra_provision.provision_ids
}

output "cassandra_host_ips" {
  value = module.cassandra_cluster.network_interface_private_ip
}

output "cassandra_seed_ips" {
  value = local.cassandra.resource_count > 0 ? slice(module.cassandra_cluster.network_interface_private_ip, 0, min(local.cassandra.resource_count, 3)) : []
}

output "cassandra_host_ids" {
  value = module.cassandra_cluster.vm_ids
}

output "network_interface_ids" {
  value = module.cassandra_cluster.network_interface_ids
}

output "cassandra_resource_count" {
  value = local.cassandra.resource_count
}

output "cassandra_start_on_initial_boot" {
  value = local.cassandra.start_on_initial_boot
}
