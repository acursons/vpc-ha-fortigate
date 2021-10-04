##############################################################################
# The main input structure is a specification of a host to be created
# other parameters are used to configure the VSI on the appropriate network
##############################################################################

variable host_spec {
    description = "The specification of the host to be created"
    type        = object({
        host_name               = string,
        host_image              = string,
        host_profile            = string,
        public_ip               = bool,
        primary_subnet          = string,
        primary_ip_spoofing     = bool,
        host_num                = string,
        primary_security_groups = list(string),
        secondary_nics          = list(object({
            attached_to   = string,
            allow_ip_spoofing = bool,
            security_grps = list(string)
        })),
        data_volumes            = list(string),
        host_init               = string,
        init_vars               = map(string)
    })
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

##############################################################################
# Various maps for connecting the host to the environment
##############################################################################

variable subnet_map {
    description = "Map of subnet names to their IDs"
    type       = map(object({
        id   = string,
        zone = string,
        cidr_block = string
    }))
}

variable security_group_map {
    description = "Map of security group names to their IDs"
    type       = map(string)
}

variable data_volume_map {
    description = "Map of data volumes to their IDs"
    type        = map(string)
}

variable ssh_key_map {
    description = "Map of ssh key name/id pairs"
    type        = map(string)
}

variable vpc_id {
    description = "The ID of the VPC in which to  create the security groups"
    type        = string
}

variable custom_image_id {
    description = "Custom image ID to be used to construct host"
    type        = string
}

variable keys {
    description = "List of API keys"
    type        = map(string)
    default     = {}
}
