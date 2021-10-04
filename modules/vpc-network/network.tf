##############################################################################
# In this environment ACLs are not utilised for restricted access
# therefore this has not been factored into the abstracted configuration
##############################################################################

resource ibm_is_network_acl multizone_acl {
    name = "${var.environment.unique_id}multizone-acl"
    vpc  = data.ibm_is_vpc.vpc.id

    dynamic rules {
        for_each = var.acl_rules

        content {
            name        = rules.value.name
            action      = rules.value.action
            source      = rules.value.source
            destination = rules.value.destination
            direction   = rules.value.direction
       }
    }
}
