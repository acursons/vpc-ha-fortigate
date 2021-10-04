##############################################################################
# Output the host information for later use
# Additional specific information can be readily added if required
##############################################################################

output host_information {
    description = "Output all host information"
    value = ibm_is_instance.vsi_host.*
}

output host_ip_addresses {
    description = "Details of the IP addresses associated with the host"
    value       = { (ibm_is_instance.vsi_host.name) = {
        primary_public  = var.host_spec.public_ip ? ibm_is_floating_ip.testacc_floatingip[0].address : "",
        primary_private = ibm_is_instance.vsi_host.primary_network_interface[0].primary_ipv4_address,
        secondary       = [for nic in ibm_is_instance.vsi_host.network_interfaces: nic.primary_ipv4_address]
    }}
}

output subnet_ip_addr_map {
    description = "Produce a map of subnet names to IP addresses"
    value       = merge(
                      {(var.host_spec.primary_subnet) = ibm_is_instance.vsi_host.primary_network_interface[0].primary_ipv4_address},
                      {for key, nic in ibm_is_instance.vsi_host.network_interfaces: var.host_spec.secondary_nics[key].attached_to => nic.primary_ipv4_address}
                  )
}

output private_ip_addr {
    description = "The private IP address for the created host"
    value       = ibm_is_instance.vsi_host.primary_network_interface[0].primary_ipv4_address
}

output host_init {
  value = var.host_spec.host_init
}

output user_data {
  value = ibm_is_instance.vsi_host.user_data
}
