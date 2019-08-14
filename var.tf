variable "Lbs" {
  description = "List containing your load balancers."
  type        = any
}

variable "LbRules" {
  description = "List containing your load balancers parameters."
  type        = any
}
variable "lb_prefix" {
  description = "Prefix applied on the load balancer resources names."
}

variable "lb_location" {
  description = "Location of the load balancer, use the RG's location if not set"
  default     = ""
}

variable "lb_resource_group_name" {
  description = "Resource group name of the load balancer."
}

variable "Lb_sku" {
  description = "SKU of the load balancer."
}

variable "subnets_ids" {
  description = "A list of subnet ids."
  type        = list(string)
}

variable "lb_additional_tags" {
  description = "Tags of the load balancer in addition to the resource group tag."
  type        = map(string)
}

variable "emptylist" {
  type    = list(string)
  default = ["null", "null"]
}
