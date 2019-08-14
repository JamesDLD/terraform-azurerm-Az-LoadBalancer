output "lb_names" {
  value = [ for x in azurerm_lb.lb: x.name]
}

output "lb_private_ip_address" {
  value = [ for x in azurerm_lb.lb: x.private_ip_address]
}

output "lb_backend_ids" {
  value = concat(
    [ for x in azurerm_lb_backend_address_pool.lb_backend: x.id],
    var.emptylist,
  )
}

output "lb_rule_ids" {
  value = [ for x in azurerm_lb_rule.lb_rule: x.id]
}

