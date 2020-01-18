variable "region" {
    default = "us-east-1"
}
variable "aws_access_key" {
    default = "XXXXXXXXXXXX"
}

variable "aws_secret_key" {
    default = "XXXXXXXXXXXXX"
}

variable "availability_zones" {
  type        = "list"
  default     = ["us-east-1a","us-east-1b"]
  description = "List of Availability Zones"
}

variable "aws_zone_one" {
    default = "us-east-1a"
}

variable "aws_zone_two" {
    default = "us-east-1b"
}

variable "ssh_key" {
    default = "fa-ssh-key.pem"
}

variable "jenkins_port" {
    default = "8080"
}

variable "jnlp_port" {
  default     = 49187
}
