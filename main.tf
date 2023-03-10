# Terraform relies on plug-ins to interact with providers including Cloud Providers, SaaS Providers and APIs
# Plugins allow for communication between two pieces of software with allows for an extension of capabilities 

# Provider - Azure Resource Manager
# Documentation is under azurerm
# We must provide which cloud provider Terraform needs to communicate with

# Provides sets of resources and data sources for Terraform to manage

# TF Registry has documentation for a whole range of providers by devs

# https://registry.terraform.io/browse/providers
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# Like an API, allows for Terraform to interact with providers e.g. as stated above.


# source - the global source address for the provider you intend to use, such as hashicorp/aws.
# version - a version constraint specifying which subset of available provider versions the module is compatible with.


# ----------------
# Providers
# 
# ----------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.46.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

# ----------------
# Resource Groups
# Lisource Groups
# ----------------

resource "azurerm_resource_group" "li-nux_server_rg" {
   name = "li-nux_server_rg"
   location = var.location
}