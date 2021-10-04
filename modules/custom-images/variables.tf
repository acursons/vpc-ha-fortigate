##############################################################################
# Variables required to create a custom image
##############################################################################

variable image_spec {
    description = "The specification of the custom image"
    type        = object({
        image_name       = string,
        cos_image_name   = string,
        bucket_base_url  = string,
        base_os          = string
    })
}

variable vnf_license {
    description = "(HIDDEN) Optional. The BYOL license key that you want your cp virtual server in a VPC to be used by registration flow during cloud-init."
    default     = ""
}

variable ibmcloud_endpoint {
    description = "(HIDDEN) The IBM Cloud environmental variable 'cloud.ibm.com' or 'test.cloud.ibm.com'"
    default     = "cloud.ibm.com"
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
