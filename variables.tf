# ----------------
# VARS
# Variables
# ----------------

variable "location" {
   type = string
   description = "Region"
   default = "Australia Southeast"
}

variable "tenant_id" {
   description = "Azure Tenant ID"
   default = "0fadf077-8bb2-47d7-82df-51b92f5807ac"
}

variable "subscription_id" {
   description = "Azure subscription"
   default = "a7e559ea-2d59-424c-a2a2-9e1480c66a9e"
}

variable "client_id" {
   description = "Azure Client ID"
   default = "541bc3bf-07a4-43a2-a960-b3cd80e20dda"
}

variable "client_secret" {
#   default = ""
}

variable "instance_size" {
   type = string
   description = "Standard_B1ls"
   default = "Standard_B1ls"
}

variable "environment" {
   type = string
   description = "Environment"
   default = "I-LAB-Li"
}