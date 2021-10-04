##############################################################################
# Top level variables
# These can be provided from a tfvars file included from the command line.
##############################################################################

variable ibmcloud_apikey {
    description = "IBM Cloud VPC API key"
    type        = string
    default     = ""
}

variable iaas_classic_username {
    description = "IBM Cloud Classic username"
    type        = string
    default     = ""
}

variable iaas_classic_api_key {
    description = "IBM Clud Classic API key"
    type        = string
    default     = ""
}

variable configuration {
    description = "The name of the configuration file to use"
    type        = string
}

variable ssh_key_map {
    description = "Map of SSH public keys to be applied to VSI hosts"
    type        = map(string)
    default     = {}
}
