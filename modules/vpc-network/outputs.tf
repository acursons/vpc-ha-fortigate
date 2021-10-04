##############################################################################
# Output the IDs of the VPC and its related subnets
##############################################################################

output vpc_id {
    description = "The ID of the created VPC"
    value       = data.ibm_is_vpc.vpc.id
}

output subnet_id_map {
    description = "Map of VPC Subnet names to IDs and zones"
    value = tomap({
        for subnet in ibm_is_subnet.subnet:
        subnet.name => { id = subnet.id, zone = subnet.zone, cidr_block = subnet.ipv4_cidr_block }
    })
}
