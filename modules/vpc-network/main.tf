##############################################################################
# Define the provider and versions
##############################################################################

terraform {
    required_version = ">= 0.13"
    required_providers {
        ibm = {
            source  = "ibm-cloud/ibm"
            version = ">= 1.16.1"
        }
     }
}

data ibm_resource_group resource_group {
    name = var.environment.resource_group
}

##############################################################################
# Create VPC, Subnets and allocate public gateways if required
# All controlled from the input parameters specified
##############################################################################

resource ibm_is_vpc vpc {
    name = "${var.environment.unique_id}${var.vpc_name}"
    classic_access            = var.classic_access
    address_prefix_management = "manual"
    resource_group            = data.ibm_resource_group.resource_group.id
    tags                      = var.environment.tags
}

data ibm_is_vpc vpc {
    depends_on = [ibm_is_vpc.vpc]
    name = "${var.environment.unique_id}${var.vpc_name}"
}

resource ibm_is_vpc_address_prefix subnet_prefix {
    for_each = var.subnets

    name  = "${var.environment.unique_id}${each.key}"
    zone  = "${var.environment.region}-${each.value["zone"]}"
    vpc   = data.ibm_is_vpc.vpc.id
    cidr  = each.value["cidr_block"]
}

# Need to generate a list of public gateways, one per zone where required
# Also a list of the subnet names required
#
locals {
    zone_gateways = distinct(flatten([
        for subnet in var.subnets:
            ["${var.environment.region}-${subnet.zone}"] if subnet.public_gateway == "true"
    ]))
    
#    subnet_names = [
#        for subnet in var.subnets:
#             "${var.environment.unique_id}${subnet.subnet_id}"
#    ]
}

resource ibm_is_public_gateway public_gateway {
    count = length(local.zone_gateways)

    name  = "${var.environment.unique_id}gateway-zone-${count.index + 1}"
    vpc   = data.ibm_is_vpc.vpc.id
    zone  = element(local.zone_gateways, count.index)
}

resource ibm_is_subnet subnet {
#    count           = length(var.subnets)
     for_each       = var.subnets

#    name            = local.subnet_names[count.index]
    name            = "${var.environment.unique_id}${each.key}"
    vpc             = data.ibm_is_vpc.vpc.id
    zone            = "${var.environment.region}-${each.value.zone}"
    resource_group  = data.ibm_resource_group.resource_group.id
    ipv4_cidr_block = ibm_is_vpc_address_prefix.subnet_prefix[each.key].cidr
    network_acl     = ibm_is_network_acl.multizone_acl.id
    
    # If this subnet requires a public gateway, then lookup the id for the gateway
    # associated with the zone in which this subnet is being created
    #
    public_gateway  =  (each.value.public_gateway
                            ? element(ibm_is_public_gateway.public_gateway.*.id,
                                      index(local.zone_gateways, "${var.environment.region}-${each.value.zone}")
                                     )
                            : null
                       )
    routing_table   =  try(ibm_is_vpc_routing_table.vpc_routing_table[each.value.routing_table].routing_table, null)
}

resource ibm_is_vpc_routing_table vpc_routing_table {
    for_each                      = var.route_tables
    
    name                          = "${var.environment.unique_id}${each.key}"
    vpc                           = data.ibm_is_vpc.vpc.id

    route_direct_link_ingress     = try(each.value["route_direct_link_ingress"], null)
    route_transit_gateway_ingress = try(each.value["route_transit_gateway_ingress"], null)
    route_vpc_zone_ingress        = try(each.value["route_vpc_zone_ingress"], null)
}


