##############################################################################
# Need to output the list security groups as name->ID pairs
##############################################################################

output security_group_map {
    description = "Map of group names to their IDs"
    value       = { for sg in ibm_is_security_group.security_group: sg.name => sg.id }
}
