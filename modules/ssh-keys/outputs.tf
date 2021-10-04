##############################################################################
# Save the IDs of all keys we create
##############################################################################

output vpc_key_map {
    description = "The VPC environment SSH Key IDs that have been created"
    value       = { for name, key in ibm_is_ssh_key.server_ssh_key: name => key.id }
}
