output host_ip_addresses {
    description = "List of IP address information for created VSI's"
    value       = try(flatten([module.vsi_hosts.host_ip_addresses, module.custom_hosts.host_ip_addresses]), [])
}
