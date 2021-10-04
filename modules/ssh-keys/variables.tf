##############################################################################
# When creating ssh keys need a map of names and key strings
##############################################################################

variable ssh_key_map {
    description = "Map of ssh key name/id pairs"
    type        = map(string)
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


