#Set the terraform backend
terraform {
  backend "azurerm" {
    storage_account_name = "infrasdbx1vpcjdld1"
    container_name       = "tfstate"
    key                  = "Az-LoadBalancer.test.tfstate"
    resource_group_name  = "infr-jdld-noprd-rg1"
  }
}

#Set the Provider
provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

#Set authentication variables
variable "tenant_id" {
  description = "Azure tenant Id."
}

variable "subscription_id" {
  description = "Azure subscription Id."
}

variable "client_id" {
  description = "Azure service principal application Id."
}

variable "client_secret" {
  description = "Azure service principal application Secret."
}

#Set resource variables

variable "Lbs" {
  default = {

    lb1 = {
      id               = "1" #Id of the load balancer use as a suffix of the load balancer name
      suffix_name      = "apa"
      subnet_iteration = "0"        #Id of the Subnet
      static_ip        = "10.0.1.4" #(Optional) Set null to get dynamic IP or delete this line
    }

    lb2 = {
      id               = "1" #Id of the load balancer use as a suffix of the load balancer name
      suffix_name      = "iis"
      subnet_iteration = "0"        #Id of the Subnet
      static_ip        = "10.0.1.5" #(Optional) Set null to get dynamic IP or delete this line
    }

  }
}

variable "LbRules" {
  default = {
    lbrules1 = {
      Id                = "1"   #Id of a the rule within the Load Balancer 
      lb_key            = "lb1" #Key of the Load Balancer
      suffix_name       = "apa" #It must equals the Lbs suffix_name
      lb_port           = "80"
      probe_port        = "80"
      backend_port      = "80"
      probe_protocol    = "Http"
      request_path      = "/"
      load_distribution = "SourceIPProtocol"
    }

    lbrules2 = {
      Id                = "2"   #Id of a the rule within the Load Balancer 
      lb_key            = "lb2" #Key of the Load Balancer
      suffix_name       = "iis" #It must equals the Lbs suffix_name
      lb_port           = "80"
      probe_port        = "80"
      backend_port      = "80"
      probe_protocol    = "Http"
      request_path      = "/"
      load_distribution = "SourceIPProtocol"
    }
  }
}


variable "location" {
  default = "westus2"
}

variable "rg_apps_name" {
  default = "infr-jdld-noprd-rg1"
}

variable "Lb_sku" {
  default = "Standard"
}

variable "additional_tags" {
  default = {
    iac = "terraform"
  }
}

#Call native Terraform resources

data "azurerm_resource_group" "rg" {
  name = var.rg_apps_name
}

resource "azurerm_virtual_network" "Demo" {
  name                = "myproductlb-perimeter-npd-vnet1"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.1.0/24"]
  tags                = data.azurerm_resource_group.rg.tags
  subnet {
    name           = "demolb1"
    address_prefix = "10.0.1.0/28"
  }
}

#Call module

module "Create-AzureRmLoadBalancer-Demo" {
  #version = "0.1.1" <-- not specifying any version here because we always test the latest one
  source                 = "JamesDLD/Az-LoadBalancer/azurerm"
  Lbs                    = var.Lbs
  lb_prefix              = "myproductlb-perimeter"
  lb_resource_group_name = data.azurerm_resource_group.rg.name
  Lb_sku                 = var.Lb_sku
  subnets_ids            = [for x in azurerm_virtual_network.Demo.subnet : x.id if x.name == "demolb1"]
  lb_additional_tags     = var.additional_tags
  LbRules                = var.LbRules
  lb_location            = var.location #(Optional) Use the RG's location if not set
}
