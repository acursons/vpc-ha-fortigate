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
# Creation of security groups
##############################################################################

resource ibm_is_security_group security_group {
    for_each       = var.security_defns
    
    name           = "${var.environment.unique_id}${each.key}-sg"
    vpc            = var.vpc_id
    resource_group = data.ibm_resource_group.resource_group.id
}

##############################################################################
# Create the rules and associate them with the appropriate group
##############################################################################

locals {
    security_rules   = flatten([
        for sc_grp, group_rules in var.security_defns: [
            for protocol, rule_def in group_rules : [
                merge({rule_grp = sc_grp}, rule_def)
             ]
        ]
    ])
}

resource ibm_is_security_group_rule security_group_rules {
    count     = length(local.security_rules)
    group     = ibm_is_security_group.security_group[local.security_rules[count.index].rule_grp].id
    direction = local.security_rules[count.index].direction

    # Dynamicaly create ICMP block if required
    #
    dynamic icmp {

        # Runs a for each loop, if the rule contains protocol icmp, it creates a single entry list
        # Otherwise the list will be empty        
        #
        for_each = (
              local.security_rules[count.index].protocol == "icmp"
              ? [local.security_rules[count.index]]
              : []
        )
        
        content {
            type = icmp.value.port_min
            code = icmp.value.port_max
        }
    } 

    # Dynamically create TCP block if required
    #
    dynamic tcp {

        # Runs a for each loop, if the rule contains protocol icmp, it creates a single entry list
        # Otherwise the list will be empty        
        #
        for_each = (
              local.security_rules[count.index].protocol == "tcp"
              ? [local.security_rules[count.index]]
              : []
        )

        content {
            port_min = tcp.value.port_min
            port_max = tcp.value.port_max
        }
    } 

    # Dynamically create UDP block if required
    #
    dynamic udp {

        # Runs a for each loop, if the rule contains protocol icmp, it creates a single entry list
        # Otherwise the list will be empty        
        #
        for_each = (
              local.security_rules[count.index].protocol == "udp"
              ? [local.security_rules[count.index]]
              : []
        )

        content {
            port_min = udp.value.port_min
            port_max = udp.value.port_max
        }
    } 
}


