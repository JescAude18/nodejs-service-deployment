variable "tenancy_ocid" {
    type        = string 
    description = "OCID of the OCI tenancy"    
}

variable "compartment_ocid" {
    type        = string
    description = "OCID of the compartment where resources will be created"
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

variable "shape" {
    type        = string
    description = "VM instance shape"
}

variable "subnet_ocid" {
    type        = string
    description = "OCID of the existing subnet where the VM will be created"
}

variable "image_ocid" {
    type        = string
    description = "OCID of the image used for VM creation"
}

variable "ssh_public_key" {
    type        = string
    description = "Public SSH key used to access the instance"
}
