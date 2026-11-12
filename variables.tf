variable "project" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}

variable "aws_access_key" {
    type        = string 
    description = "AWS access key to configure workstation"
    sensitive   = true 
}

variable "aws_secret_key" {
    type        = string 
    description = "AWS secret key to configure workstation"
    sensitive   = true 
}

variable "ssh_password" {
    type        = string 
    description = "ssh password for ec2-user to run destory time provisioner"
    sensitive   = true 
}
