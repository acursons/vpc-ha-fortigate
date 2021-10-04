##############################################################################
# Define the provider and versions
##############################################################################

terraform {
    required_version = ">= 0.13"
    required_providers {
        ibm = {
            source  = "ibm-cloud/ibm"
            version = ">= 1.23.0"
        }
     }
}

##############################################################################
# Pre-existing data sources (flagged as dependencies at parent level)
##############################################################################

data ibm_is_vpc_routing_tables vpc_routing_tables {
    vpc = var.vpc_id
}

locals {

    # Merge the table name into the entries creating a single list
    #
    route_table_entries = flatten([
        for name, defn in var.route_tables: [
            for table_entry in defn.routes: [
                merge({table = name}, table_entry)
            ]
        ]
    ])
    
    # Now build a map of created tables and their IDs
    #
    routing_tables  = data.ibm_is_vpc_routing_tables.vpc_routing_tables.routing_tables
    route_table_map = {for entry in local.routing_tables:
                           trimprefix(entry.name, var.environment.unique_id) => entry.routing_table
                      }
}

##############################################################################
# Create a VPC based routing table and its associated routes
##############################################################################

resource ibm_is_vpc_routing_table_route vpc_routing_table_route {
    count         = length(local.route_table_entries)
    
    vpc           = var.vpc_id
    routing_table = local.route_table_map[local.route_table_entries[count.index].table]
    zone          = "${var.environment.region}-${local.route_table_entries[count.index].zone}"

    destination   = local.route_table_entries[count.index].destination
    action        = try(local.route_table_entries[count.index].action, null)
    next_hop      = try(tomap(var.gateway_map)[local.route_table_entries[count.index].next_hop], "0.0.0.0")
}
