##############################################################################
# Define the provider and versions
##############################################################################

terraform {
    required_version = ">= 0.13"
    required_providers {
        ibm = {
            source  = "ibm-cloud/ibm"
            version = ">= 1.16.1"
        }
     }
}

data ibm_resource_group resource_group {
    name = var.environment.resource_group
}

##############################################################################
# Create a data volume for allocation to one or more hosts
##############################################################################

resource ibm_is_volume data_volumes {
    name           = "${var.environment.unique_id}${var.volume_spec.name}"
    profile        = var.volume_spec.profile
    zone           = "${var.environment.region}-${var.volume_spec.zone}"
    capacity       = var.volume_spec.capacity
    
    resource_group = data.ibm_resource_group.resource_group.id
    tags           = var.environment.tags
}
