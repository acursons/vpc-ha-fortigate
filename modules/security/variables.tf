##############################################################################
# Each security group is created from a list of
# protocols, ports, and direction which are to be permitted.
##############################################################################

variable security_defns {
    description = "Security definition map of names and rules"
    type        = map(list(object({
        direction = string,
        protocol  = string,
        port_min  = string,
        port_max  = string
    })))
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

variable vpc_id {
    description = "The ID of the VPC in which to  create the security groups"
    type        = string
}


