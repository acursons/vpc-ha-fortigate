##############################################################################
# Output the ID of the created volume
##############################################################################

output data_volume_id {
    description = "Created volume ID"
    value       = ibm_is_volume.data_volumes.*.id
}
