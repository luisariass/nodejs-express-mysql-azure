// Base infrastructure and MySQL VM
resource "azurerm_resource_group" "rg" {
  name     = "mysql-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "mysql-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "mysql_subnet" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Web"]
}

// Network Security Group for MySQL VM - Only allow SSH from controller IP
resource "azurerm_network_security_group" "mysql_nsg" {
  name                = "mysql-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.controller_ip_address // Variable para la IP del controlador
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "MySQL"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "10.0.2.0/24" // Subnet de la App Service
    destination_address_prefix = "*"
  }
}
// Network Interface for MySQL VM
resource "azurerm_network_interface" "mysql_nic" {
  name                = "mysql-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mysql_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mysql_public_ip.id
  }
}

// Public IP for MySQL VM (needed for Ansible provisioning)
resource "azurerm_public_ip" "mysql_public_ip" {
  name                = "mysql-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

// Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "mysql_nsg_association" {
  network_interface_id      = azurerm_network_interface.mysql_nic.id
  network_security_group_id = azurerm_network_security_group.mysql_nsg.id
}
// MySQL VM
resource "azurerm_linux_virtual_machine" "mysql_vm" {
  name                = "mysql-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  
  network_interface_ids = [
    azurerm_network_interface.mysql_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  // Provision MySQL with Ansible
  provisioner "local-exec"{
    command = "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i 'adminuser@${azurerm_public_ip.mysql_public_ip.ip_address},' --private-key=~/.ssh/id_rsa --ssh-common-args='-o StrictHostKeyChecking=no' ~/nodejs-express-mysql-1/ansible/mysql_setup.yml -e 'app_subnet_cidr=10.0.2.0/24' -e 'controller_ip=${var.controller_ip_address}'"
  }
}