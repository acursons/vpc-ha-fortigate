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
# Create ssh keys in the VPC environment
##############################################################################

resource ibm_is_ssh_key server_ssh_key {
    for_each       = var.ssh_key_map
  
    name           = "${var.environment.unique_id}${each.key}"
    public_key     = each.value
    resource_group = data.ibm_resource_group.resource_group.id
    tags           = var.environment.tags
}
