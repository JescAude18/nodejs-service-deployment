variable "tenancy_ocid" {
    type        = string 
    description = "OCID of the OCI tenancy"    
}

variable "user_ocid" {
    type        = string
    description = "OCID of the OCI user"
}

variable "fingerprint" {
    type        = string
    description = "Fingerprint of the OCI API key"
}

variable "private_key_path" {
    type        = string
    description = "Path to the OCI API private key"
}

variable "region" {
    type        = string
    description = "OCI region where resources will be created"
}
