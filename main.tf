terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  skip_provider_registration = false
  features {}
}

resource "azurerm_resource_group" "tf_mysql_rg" {
  name     = "terraform-mysql"
  location = "eastus"
}

resource "azurerm_virtual_network" "tf_mysql_network" {
  name                = "tf-mysql-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tf_mysql_rg.location
  resource_group_name = azurerm_resource_group.tf_mysql_rg.name
}

resource "azurerm_subnet" "tf_mysql_subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.tf_mysql_rg.name
  virtual_network_name = azurerm_virtual_network.tf_mysql_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "tf_mysql_public_ip" {
  name                = "tf-mysql-public-ip"
  resource_group_name = azurerm_resource_group.tf_mysql_rg.name
  location            = azurerm_resource_group.tf_mysql_rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "tf_mysql_security_group" {
  name                = "tf-mysql-security-group"
  location            = azurerm_resource_group.tf_mysql_rg.location
  resource_group_name = azurerm_resource_group.tf_mysql_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "MySql"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "tf_mysql_network_interface" {
  name                = "tf-mysql-nic"
  location            = azurerm_resource_group.tf_mysql_rg.location
  resource_group_name = azurerm_resource_group.tf_mysql_rg.name

  ip_configuration {
    name                          = "tf-mysql-configuration"
    subnet_id                     = azurerm_subnet.tf_mysql_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf_mysql_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "tf_mysql_ni_sg_association" {
  network_interface_id      = azurerm_network_interface.tf_mysql_network_interface.id
  network_security_group_id = azurerm_network_security_group.tf_mysql_security_group.id
}

resource "azurerm_linux_virtual_machine" "tf_mysql_vm" {
  name                  = "tf-mysql-vm"
  location              = azurerm_resource_group.tf_mysql_rg.location
  resource_group_name   = azurerm_resource_group.tf_mysql_rg.name
  network_interface_ids = [azurerm_network_interface.tf_mysql_network_interface.id]
  size               = "Standard_DS1_v2"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "tf-mysql-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  computer_name                   = "tf-mysql"
  admin_username                  = var.user.name
  admin_password                  = var.user.password
  disable_password_authentication = false
}

resource "null_resource" "tf_mysql_install" {
  triggers = {
    order = azurerm_linux_virtual_machine.tf_mysql_vm.id
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.user.name
      password = var.user.password
      host     = azurerm_public_ip.tf_mysql_public_ip.ip_address
    }

    script = "bootstrap.sh"
  }
}
