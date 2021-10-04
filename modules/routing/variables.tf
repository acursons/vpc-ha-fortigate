##############################################################################
# The main input structure is a specification of route tables to be created
##############################################################################

variable route_tables {
    description = "The route tables if any to be used in the VPC"
    type        = map(object({
        options = map(string),
        routes  = list(map(string))
    }))
}

# The gateway map is built after the gateway hosts and maps the
# gateway/subnet pair to its attached IP addresses
#
variable gateway_map {
    description = "Map of gateway.subnet -> IP addresses"
    type        = map(string)
}

variable vpc_id {
    description = "The VPC with which the route tables are to be associated"
    type        = string
}

variable environment {
    description = "The general environment information from the configuration file"
    type        = object({
        unique_id      = string,
        region         = string,
        resource_group = string,
        tags           = list(string)
    })
}
