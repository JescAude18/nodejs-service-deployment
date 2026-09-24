resource "oci_core_instance" "roadmapsh_vm2" {
    compartment_id = var.compartment_ocid
    availability_domain = data.oci_identity_availability_domain.ad.name
    display_name = "roadmapsh_vm2"
    shape = var.shape
    
    create_vnic_details {
        subnet_id        = var.subnet_ocid
        display_name     = "roadmapsh_vnic2"
        assign_public_ip = true
    }

    source_details {
        source_type = "image"
        source_id   = var.image_ocid
    }

    metadata = {
        ssh_authorized_keys = var.ssh_public_key
    }
}
