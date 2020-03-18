output "lbs" {
  description = "Map output of the Load Balancers"
  value       = { for k, b in azurerm_lb.lb : k => b }
}

output "lb_backend_address_pools" {
  description = "Map output of the Load Balancers Address Pools"
  value       = { for k, b in azurerm_lb_backend_address_pool.lb_backend : k => b }
}

output "lb_rules" {
  description = "Map output of the Load Balancers Rules"
  value       = { for k, b in azurerm_lb_rule.lb_rule : k => b }
}


