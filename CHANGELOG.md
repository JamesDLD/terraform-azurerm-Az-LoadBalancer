## 0.2.1 (November 10, 2022)

FEATURES:
* Upgrade to Terraform 1.3.4 and above.
* Upgrade to AzureRm provider 3.31.0 and above.

ENHANCEMENTS:
* Delete the deprecated version constraint in the azurerm provider.
* Code formatting with IntelliJ and `terraform fmt -recursive`.
* Add a Add a change log file.

BUG FIXES:
* Delete the deprecated option `resource_group_name`on the resources `azurerm_lb_backend_address_pool`, `azurerm_lb_probe` and `azurerm_lb_rule`.
* Replace `backend_address_pool_id` with `backend_address_pool_ids`in the resource `azurerm_lb_rule`.