variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "username" {
  description = "Username"
}

variable "password" {
  description = "Password"
}

variable "poolsize" {
  description = "How many VM's in the Load Balancer pool?"
}
