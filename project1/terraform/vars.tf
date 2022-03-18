variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "udacity-project1"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}

variable "username" {
  description = "Username"
  default = "gfalace"
}

variable "password" {
  description = "Password"
  default = "PaSSWoRD-123"
}

variable "poolsize" {
  description = "How many VM's in the Load Balancer pool?"
  default = 3
  validation {
    condition = var.poolsize >= 2 && var.poolsize < 5
    error_message = "Min 2, Max 5 virtual machines."
  }
}
