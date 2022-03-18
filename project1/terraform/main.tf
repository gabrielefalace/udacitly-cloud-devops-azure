provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal_nic_ip_config"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_public_ip" "main" {
  name                = "publicStaticIP"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "MainSecurityGroup"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowTrafficOnInternalSubnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_lb" "main" {
  name                = "Project1LoadBalancer"
  location            = "East US"
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "publicStaticIP"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  network_interface_id    = azurerm_network_interface.main.id
  ip_configuration_name   = "internal_nic_ip_config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}


# Virtual Machines Availability Set

resource "azurerm_availability_set" "main" {
  name                = "lb-aset"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = "Production"
  }
}

# NICs for VMs in the pool

resource "azurerm_network_interface" "pool_nic" {
  count = "${var.poolsize}"
  name                = "${var.prefix}-pool-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal_nic_ip_config"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "Production"
  }
}

# VMs for the LB pool

resource "azurerm_linux_virtual_machine" "main" {
  count = "${var.poolsize}"
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.pool_nic[count.index].id,  //Template "counter" here!
  ]

  source_image_id = "/subscriptions/efa42e01-27ef-4660-b3e7-2f62a24bd429/resourceGroups/udacity-demo-rg/providers/Microsoft.Compute/images/myPackerUbuntu"
  availability_set_id = azurerm_availability_set.main.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "Production"
  }
}
