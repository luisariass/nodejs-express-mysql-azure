# Variables para la webapp
variable "mysql_private_ip" {
  description = "Private IP address of the MySQL VM"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "dbuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "testdb"
}

# Resource Group
resource "azurerm_resource_group" "app_rg" {
  name     = "app-resources"
  location = "West Europe"
}

# Referencia a la red virtual existente
data "azurerm_virtual_network" "existing_vnet" {
  name                = "mysql-network"
  resource_group_name = "mysql-resources"  # El nombre del grupo de recursos donde está la VNET
}

# Referencia al subnet existente (en lugar de crearlo)
data "azurerm_subnet" "app_subnet" {
  name                 = "app-subnet"
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_virtual_network.existing_vnet.resource_group_name
}

# App Service Plan
resource "azurerm_service_plan" "app_plan" {
  name                = "nodejs-app-plan"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  os_type             = "Linux"
  sku_name            = "F1"  # Basic tier, puedes cambiar a P1V2 para producción
}

# Generar sufijo aleatorio para el nombre único del App Service
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# App Service
resource "azurerm_linux_web_app" "app" {
  name                = "nodejs-mysql-app-${random_string.suffix.result}"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    application_stack {
      node_version = "16-lts"
    }
    always_on          = false
    http2_enabled      = true
    minimum_tls_version = "1.2"
    ftps_state         = "Disabled"
  }

  app_settings = {
    "DB_HOST"     = var.mysql_private_ip
    "DB_USER"     = var.db_user
    "DB_PASSWORD" = var.db_password
    "DB_NAME"     = var.db_name
    "PORT"        = "8080"
  }

  https_only = true
  
  # VNet Integration - conectar App Service con el subnet
  virtual_network_subnet_id = azurerm_subnet.app_subnet.id
}

# Outputs
output "app_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "app_name" {
  value = azurerm_linux_web_app.app.name
}