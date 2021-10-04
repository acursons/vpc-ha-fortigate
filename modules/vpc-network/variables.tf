##############################################################################
# Input variables to VPC creation process
##############################################################################

variable vpc_name {
    description = "The name of the VPC to be created"
    type        = string
}

variable classic_access {
    description = "Flag indicating whether VPC is to have Classic access enabled"
    type        = bool
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

variable route_tables {
    description = "The route tables if any to be used in the VPC"
    type        = map(object({
        options = map(string),
        routes  = list(map(string)),
    }))
}

variable subnets {
    description = "List of subnets to be associated with the VPC"
    type        = map(map(string))
}

variable acl_rules {
    description = "Default set of ACL rules for unrestricted access"
    default     = [
        {
            name        = "egress"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "inbound"
        },
        {
            name        = "ingress"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "outbound"
        }
    ]
}
