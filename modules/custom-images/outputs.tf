##############################################################################
# Output the ID of the created custom images
##############################################################################

output image_id {
    description = "ID of the newly created image"
    value       = ibm_is_image.custom_images.*.id
}

