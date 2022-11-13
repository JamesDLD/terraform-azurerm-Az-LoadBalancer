Test
-----
[![Build Status](https://dev.azure.com/jamesdld23/vpc_lab/_apis/build/status/JamesDLD.terraform-azurerm-Az-LoadBalancer?branchName=master)](https://dev.azure.com/jamesdld23/vpc_lab/_build/latest?definitionId=14&branchName=master)

Requirement
-----

- Terraform v0.12.23 and above.
- AzureRm provider version 2.1 and above.

Terraform resources used within the module
-----

| Resource | Description |
|------|-------------|
| [azurerm_resource_group](https://www.terraform.io/docs/providers/azurerm/d/resource_group.html) | Get the Resource Group, re use it's tags for the sub resources. |
| [azurerm_lb](https://www.terraform.io/docs/providers/azurerm/r/loadbalancer.html) | Manages a Load Balancer Resource. |
| [azurerm_lb_backend_address_pool](https://www.terraform.io/docs/providers/azurerm/r/loadbalancer_backend_address_pool.html) | Manages a Load Balancer Backend Address Pool. |
| [azurerm_lb_probe](https://www.terraform.io/docs/providers/azurerm/r/loadbalancer_probe.html) | Manages a LoadBalancer Probe Resource. |
| [azurerm_lb_rule](https://www.terraform.io/docs/providers/azurerm/r/loadbalancer_rule.html) | Manages a Load Balancer Rule. |

Examples
-----

| Name | Description |
|------|-------------|
| complete | Create the following objects : 1 vnet/subnet with 2 Internal LB, 2 LB rules with an Http probe. |