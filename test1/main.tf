#Set the terraform backend
terraform {
  backend "azurerm" {
    storage_account_name = "infrsand1vpcjdld1"
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
variable "virtual_networks" {
  default = {
    vnet1 = {
      id            = "1"
      prefix        = "npd"
      address_space = ["10.0.1.0/24"]
    }
  }
}

variable "subnets" {
  default = {
    subnet1 = {
      vnet_key       = "vnet1"       #(Mandatory) 
      name           = "demolb1"     #(Mandatory) 
      address_prefix = "10.0.1.0/28" #(Mandatory) 
    }
  }
}

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
  default = "francecentral"
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

#Call module
module "Az-VirtualNetwork-Demo" {
  source                      = "git::https://github.com/JamesDLD/terraform-azurerm-Az-VirtualNetwork.git"
  net_prefix                  = "myproductlb-perimeter"
  net_location                = var.location
  network_resource_group_name = "infr-jdld-noprd-rg2"
  virtual_networks            = var.virtual_networks
  subnets                     = var.subnets
  route_tables                = []
  network_security_groups     = []
  net_additional_tags         = var.additional_tags
}

module "Create-AzureRmLoadBalancer-Demo" {
  source                 = "git::https://github.com/JamesDLD/terraform-azurerm-Az-LoadBalancer.git"
  Lbs                    = var.Lbs
  lb_prefix              = "myproductlb-perimeter"
  lb_resource_group_name = "infr-jdld-noprd-rg2"
  Lb_sku                 = var.Lb_sku
  subnets_ids            = module.Az-VirtualNetwork-Demo.subnet_ids
  lb_additional_tags     = var.additional_tags
  LbRules                = var.LbRules
  lb_location            = var.location #(Optional) Use the RG's location if not set
}

