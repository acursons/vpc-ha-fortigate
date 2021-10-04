##############################################################################
# Define the provider and versions
##############################################################################

locals {
    config    = yamldecode(file("${var.configuration}.yaml")).environment
}

terraform {
    required_version = ">= 0.13"
    required_providers {
        ibm = {
            source  = "ibm-cloud/ibm"
            version = "= 1.23.0"
        }
     }
}


provider ibm {
            ibmcloud_api_key      = var.ibmcloud_apikey
            iaas_classic_username = var.iaas_classic_username
            iaas_classic_api_key  = var.iaas_classic_api_key
            region                = local.config.region
}


