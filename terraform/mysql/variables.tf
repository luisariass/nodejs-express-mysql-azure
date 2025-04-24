variable "controller_ip_address" {
  description = "IP address of the controller machine (your machine)"
  type        = string
}

variable "location" {
  description = "Azure location for resources"
  default     = "East US"
}