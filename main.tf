# -
# - Data Resource
# -

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "lb" {
  name = var.lb_resource_group_name
}

locals {
  location = var.lb_location == "" ? data.azurerm_resource_group.lb.location : var.lb_location
  tags     = merge(var.lb_additional_tags, data.azurerm_resource_group.lb.tags)
}

# -
# - Resource
# -
resource "azurerm_lb" "lb" {
  for_each            = var.Lbs
  name                = "${var.lb_prefix}-${each.value["suffix_name"]}-lb${each.value["id"]}"
  location            = local.location
  resource_group_name = var.lb_resource_group_name
  sku                 = var.Lb_sku

  frontend_ip_configuration {
    name                          = "${var.lb_prefix}-${each.value["suffix_name"]}-nic1-LBCFG"
    subnet_id                     = element(var.subnets_ids, each.value["subnet_iteration"])
    private_ip_address_allocation = lookup(each.value, "static_ip", null) == null ? "dynamic" : "static"
    private_ip_address            = lookup(each.value, "static_ip", null)
  }

  tags = local.tags
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  for_each            = var.Lbs
  resource_group_name = var.lb_resource_group_name
  name                = "${var.lb_prefix}-${each.value["suffix_name"]}-bckpool1"

  #This forces a destroy when adding a new lb --> loadbalancer_id     = lookup(azurerm_lb.lb, each.key)["id"]
  loadbalancer_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.lb_resource_group_name}/providers/Microsoft.Network/loadBalancers/${var.lb_prefix}-${each.value["suffix_name"]}-lb${each.value["id"]}"
  depends_on      = [azurerm_lb.lb]
}

resource "azurerm_lb_probe" "lb_probe" {
  for_each            = var.LbRules
  resource_group_name = var.lb_resource_group_name
  name                = "${var.lb_prefix}-${each.value["suffix_name"]}-probe${each.value["Id"]}"
  port                = each.value["probe_port"]
  protocol            = each.value["probe_protocol"]
  request_path        = each.value["probe_protocol"] == "Tcp" ? "" : each.value["request_path"]

  #This forces a destroy when adding a new lb --> loadbalancer_id     = lookup(azurerm_lb.lb, each.value["lb_key"])["id"]
  depends_on      = [azurerm_lb.lb]
  loadbalancer_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.lb_resource_group_name}/providers/Microsoft.Network/loadBalancers/${var.lb_prefix}-${lookup(var.Lbs, each.value["lb_key"], "wrong_lb_key_in_LbRules")["suffix_name"]}-lb${lookup(var.Lbs, each.value["lb_key"], "wrong_lb_key_in_LbRules")["id"]}"
}

resource "azurerm_lb_rule" "lb_rule" {
  for_each                       = var.LbRules
  resource_group_name            = var.lb_resource_group_name
  name                           = "${var.lb_prefix}-${each.value["suffix_name"]}-rule${each.value["Id"]}"
  protocol                       = "Tcp"
  frontend_port                  = each.value["lb_port"]
  backend_port                   = each.value["backend_port"]
  frontend_ip_configuration_name = "${var.lb_prefix}-${each.value["suffix_name"]}-nic1-LBCFG"
  backend_address_pool_id = lookup(
    azurerm_lb_backend_address_pool.lb_backend,
    each.value["lb_key"],
  )["id"]
  probe_id                = lookup(azurerm_lb_probe.lb_probe, each.key)["id"]
  load_distribution       = each.value["load_distribution"]
  idle_timeout_in_minutes = 4

  #This forces a destroy when adding a new lb --> loadbalancer_id     = lookup(azurerm_lb.lb, each.value["lb_key"])["id"]
  depends_on      = [azurerm_lb.lb]
  loadbalancer_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.lb_resource_group_name}/providers/Microsoft.Network/loadBalancers/${var.lb_prefix}-${lookup(var.Lbs, each.value["lb_key"], "wrong_lb_key_in_LbRules")["suffix_name"]}-lb${lookup(var.Lbs, each.value["lb_key"], "wrong_lb_key_in_LbRules")["id"]}"
}

