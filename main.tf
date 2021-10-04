##############################################################################
# Only building modules at this level so decode the configuration file
# Apply the VPC based contents
##############################################################################

locals {
    envDef = yamldecode(file("./${var.configuration}.yaml"))
    
    do_vpc = try(length(local.envDef.vpc) > 0, false)
    
    keys = tomap({
      apikey = var.ibmcloud_apikey
      classic_username = var.iaas_classic_username
      classic_api_key = var.iaas_classic_api_key
    })
}

# If a VPC defn exists make it (count = 1) else ignore
#
module vpc {
    count             = local.do_vpc ? 1 : 0
    source            = "./modules/vpc-network"

    classic_access    = try(local.envDef.vpc.classic_access, false)
    vpc_name          = try(local.envDef.vpc.name, "")
    route_tables      = try(local.envDef.vpc.route_tables, {})
    subnets           = try(local.envDef.vpc.subnets, [])

    environment       = local.envDef.environment
}

# Create SSH keys for VPC environment if we are building a VPC and SSH keys have be specified
#
module ssh_keys {
    depends_on        = [module.vpc]
    count             = local.do_vpc ? 1 : 0
    source            = "./modules/ssh-keys"
    
    ssh_key_map       = var.ssh_key_map
    environment       = local.envDef.environment
}

# Create Security Groups for VPC environment if we are building a VPC and
# a set of Security Groups have been specified
#
module security_groups {
    depends_on        = [module.vpc]
    count             = local.do_vpc ? 1 : 0
    source            = "./modules/security"
    
    vpc_id            = try(module.vpc[0].vpc_id, "")
    
    security_defns    = try(local.envDef.security_rules, {})
    
    environment       = local.envDef.environment
}

# Create a set of Data Volumes if required and generate a map between their names and IDs
#
module data_volumes {
    depends_on        = [module.vpc]
    for_each          = try(local.envDef.data_volumes, {})
    source            = "./modules/data-volume"
    
    volume_spec       = each.value

    environment       = local.envDef.environment
}

locals {
    data_volume_map = {for key, vol in module.data_volumes: key => vol.data_volume_id[0]}
}

# Create a set of Custom Images if required and generate a map between their names and IDs
#
module custom_images {
    depends_on        = [module.vpc]
    for_each          = try(local.envDef.custom_imgs, {})
    source            = "./modules/custom-images"
    
    image_spec        = each.value

    environment       = local.envDef.environment
}

locals {
    custom_image_map = {for key, img in module.custom_images: key => img.image_id[0]}
}

# Create the VSI hosts and link them to the appropriate subnets and data volumes
#
module vsi_hosts { 
    depends_on         = [module.vpc, module.security_groups, module.ssh_keys, module.data_volumes]
    for_each           = try(local.envDef.vpc_hosts, {})
    source             = "./modules/host-vsi"

    vpc_id             = try(module.vpc[0].vpc_id, "")
    subnet_map         = try(module.vpc.*.subnet_id_map[0], {})
    ssh_key_map        = try(module.ssh_keys.*.vpc_key_map[0], {})
    
    host_spec          = each.value
    
    custom_image_id    = ""
    security_group_map = try(module.security_groups.*.security_group_map[0], {})
    environment        = local.envDef.environment
    data_volume_map    = local.data_volume_map
}

# Create the Custom hosts and link them to the appropriate subnets and data volumes
#
module custom_hosts {
    depends_on         = [module.vpc, module.security_groups, module.ssh_keys, module.custom_images]
    for_each           = try(local.envDef.custom_hosts, {})
    source             = "./modules/host-vsi"

    vpc_id             = try(module.vpc[0].vpc_id, "")
    subnet_map         = try(module.vpc.*.subnet_id_map[0], {})
    ssh_key_map        = try(module.ssh_keys.*.vpc_key_map[0], {})

    host_spec          = each.value

    custom_image_id    = local.custom_image_map[each.value.host_image]
    security_group_map = try(module.security_groups.*.security_group_map[0], {})
    environment        = local.envDef.environment
    data_volume_map    = local.data_volume_map
    keys               = local.keys
}

# Create routing table entries and apply to tables
# Need to aggregate the gateway IP address maps
#
locals {
    depends_on = [module.custom_hosts]
    
    temp_res = flatten([for hkey, host in module.custom_hosts: {
                       for snkey, value in host.subnet_ip_addr_map: 
                           "${hkey}.${snkey}" => value
                       }
               ])
    gateway_map=try(local.temp_res[0], {})
}

module route_table_entries {
    depends_on         = [module.vpc, module.custom_hosts]
    count              = local.do_vpc ? 1 : 0
    source             = "./modules/routing"

    route_tables       = try(local.envDef.vpc.route_tables, {})

    vpc_id             = try(module.vpc[0].vpc_id, "")
    gateway_map        = try(local.gateway_map, {})
    environment        = local.envDef.environment
}

