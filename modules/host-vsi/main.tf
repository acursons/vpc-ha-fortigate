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
# Create a VPC based VSI and associate it with its defined subnets
##############################################################################


data ibm_is_volume data_volumes {
    count = length(var.host_spec.data_volumes)
    name = "${var.environment.unique_id}${var.host_spec.data_volumes[count.index]}"
}

locals {
    secondary_nics = try(var.host_spec.secondary_nics, [])
    datavolume_info = data.ibm_is_volume.data_volumes
}

resource ibm_is_instance vsi_host {
    name           = "${var.environment.unique_id}${var.host_spec.host_name}"
    image          = (length(var.custom_image_id) == 0) ? var.host_spec.host_image : var.custom_image_id
    profile        = var.host_spec.host_profile
    resource_group = data.ibm_resource_group.resource_group.id
    tags           = var.environment.tags
  
    primary_network_interface {
        name            = "eth0"
        subnet          = var.subnet_map["${var.environment.unique_id}${var.host_spec.primary_subnet}"].id
        allow_ip_spoofing = var.host_spec.primary_ip_spoofing
        primary_ipv4_address = cidrhost(var.subnet_map["${var.environment.unique_id}${var.host_spec.primary_subnet}"].cidr_block, var.host_spec.host_num)
        
        # Find each of the desired security groups from the ID map and add them to the interface
        # The map is indexed on the security group name of the form "{unique_id}{group name}-sg"
        #
        security_groups = [
            for group in var.host_spec.primary_security_groups:
            var.security_group_map[format("${var.environment.unique_id}%s-sg",group)]
        ]
    }
    
    dynamic network_interfaces {
        for_each = local.secondary_nics
        
        content {
            name            = "eth${network_interfaces.key + 1}"
            subnet          = var.subnet_map["${var.environment.unique_id}${network_interfaces.value.attached_to}"].id
            allow_ip_spoofing = network_interfaces.value.allow_ip_spoofing
            primary_ipv4_address = cidrhost(var.subnet_map["${var.environment.unique_id}${network_interfaces.value.attached_to}"].cidr_block, var.host_spec.host_num)


            # Find each of the desired security groups from the ID map and add them to the interface
            # The map is indexed on the security group name of the form "{unique_id}{group name}-sg"
            #
            security_groups = [
                for group in network_interfaces.value.security_grps :
                var.security_group_map[format("${var.environment.unique_id}%s-sg",group)]
            ]
        }
    }
    
    # Attach the desired volume from the volume set
    #
#    volumes        = [for vol in var.host_spec.data_volumes: var.data_volume_map[vol]]
    volumes        = [for vol in data.ibm_is_volume.data_volumes: vol.id]
    vpc            = var.vpc_id
    zone           = var.subnet_map["${var.environment.unique_id}${var.host_spec.primary_subnet}"].zone
    keys           = values(var.ssh_key_map)
    
    user_data      = length(var.host_spec.host_init) == 0 ? null : templatefile(var.host_spec.host_init, merge(var.host_spec.init_vars, {apikey = var.keys["apikey"], region = var.environment.region} ))
}

resource ibm_is_floating_ip testacc_floatingip {
  count  = var.host_spec.public_ip ? 1 : 0
  
  name   = "${var.environment.unique_id}${var.host_spec.host_name}-fip"
  target = ibm_is_instance.vsi_host.primary_network_interface.0.id
}

