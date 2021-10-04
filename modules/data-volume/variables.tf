##############################################################################
# The input to the volume creation process is a
# volume specification object
##############################################################################

variable volume_spec {
    description = "The information required to provision a storage volume"
    type        = object({
        name     = string,
        profile  = string,
        zone     = number,
        capacity = number
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


