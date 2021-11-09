terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

variable "DATASOURCE_USERNAME" {}
variable "DATASOURCE_PASSWORD" {}
variable "LINUX_ADMIN_NAME" {}

#######################################################################################################################

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "project_rg" {
  location = "westeurope"
  name = "eSchoolResourceGroup"
}

resource "azurerm_virtual_network" "project_virtual_network" {
  address_space = ["10.0.0.0/16"]
  location = "westeurope"
  name = "eSchoolVirtualNetwork"
  resource_group_name = azurerm_resource_group.project_rg.name
}

resource "azurerm_subnet" "project_subnet" {
  name = "eSchoolSubnet"
  resource_group_name = azurerm_resource_group.project_rg.name
  virtual_network_name = azurerm_virtual_network.project_virtual_network.name
  address_prefixes = ["10.0.0.0/24"]
}

#########################################DATABASE SERVER################################################################

resource "azurerm_public_ip" "db_public_ip" {
  allocation_method = "Dynamic"
  location = "westeurope"
  name = "DBServerPublicIP"
  resource_group_name = azurerm_resource_group.project_rg.name
}

resource "azurerm_network_interface" "db_network_interface" {
  location = "westeurope"
  name = "eSchoolDataBaseServerNetworkInterface"
  resource_group_name = azurerm_resource_group.project_rg.name

  ip_configuration {
    name = "DataBaseServerIPConfiguration"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.project_subnet.id
    public_ip_address_id = azurerm_public_ip.db_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "db_srv" {
  admin_username = var.LINUX_ADMIN_NAME
  location = "westeurope"
  name = "DataBaseServer"
  network_interface_ids = [azurerm_network_interface.db_network_interface.id]
  resource_group_name = azurerm_resource_group.project_rg.name
  size = "Standard_D2s_v3"

  custom_data = base64encode(templatefile("mysql_db_srv_startup.sh", {
    DATASOURCE_USERNAME = var.DATASOURCE_USERNAME,
    DATASOURCE_PASSWORD = var.DATASOURCE_PASSWORD
  }))

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    public_key = file("azure_key.pub")
    username = var.LINUX_ADMIN_NAME
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}

#########################################BACKEND SERVER#################################################################

resource "azurerm_public_ip" "be_public_ip" {
  allocation_method = "Dynamic"
  location = "westeurope"
  name = "BackEndServerPublicIP"
  resource_group_name = azurerm_resource_group.project_rg.name
}

resource "azurerm_network_interface" "be_network_interface" {
  location = "westeurope"
  name = "eSchoolBackEndServerNetworkInterface"
  resource_group_name = azurerm_resource_group.project_rg.name

  ip_configuration {
    name = "BackEndServerIPConfiguration"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.project_subnet.id
    public_ip_address_id = azurerm_public_ip.be_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "be_srv" {
  admin_username = var.LINUX_ADMIN_NAME
  location = "westeurope"
  name = "eSchoolBackEndServer"
  network_interface_ids = [azurerm_network_interface.be_network_interface.id]
  resource_group_name = azurerm_resource_group.project_rg.name
  size = "Standard_D2s_v3"

  custom_data = base64encode(templatefile("be_srv_startup.sh", {
    DATASOURCE_USERNAME = var.DATASOURCE_USERNAME,
    DATASOURCE_PASSWORD = var.DATASOURCE_PASSWORD,
    DB_SRV_IP = azurerm_network_interface.db_network_interface.private_ip_address
  }))

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    public_key = file("azure_key.pub")
    username = var.LINUX_ADMIN_NAME
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}