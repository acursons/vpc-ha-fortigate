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
# Create Custom Image
##############################################################################

resource ibm_is_image custom_images {
    href             = "${var.image_spec.bucket_base_url}/${var.image_spec.cos_image_name}"
    name             = "${var.environment.unique_id}${var.image_spec.image_name}"
    operating_system = var.image_spec.base_os
    resource_group   = data.ibm_resource_group.resource_group.id
    tags             = var.environment.tags
  
    timeouts {
        create = "30m"
        delete = "10m"
    }
}
