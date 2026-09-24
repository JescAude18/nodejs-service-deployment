data "oci_identity_availability_domain" "ad" {
    compartment_id = var.compartment_ocid
    ad_number = 1
}
