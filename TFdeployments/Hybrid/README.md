# Hybrid-Networking Lab

This template creates three VNETs in Azure, VNET1 and VNET2 are in the West region and are peered together.  VNET2 and VNET3 (East region) are connected using a Site to Site VPN.

VNET2 allows VNET1 to use gateway transit for access to VNET3. 

## Optional Modules

### Compute (Jumpbox)

A VM to be used as a jumpbox is created in VNET 1. 

### AKS

This module will deploy a 2-node Linux cluster into an existing VNET using the Azure network plugin (AzureCNI).

### Application Gateway

This mondule will deploy an Application Gateway in VNET 2 with a public IP address.  The backend pool is currently empty. 

### Bastion Host

The Bastion Host feature is currently in preview and only available in the following regions: West US, East US, West Europe, South Central US, Austrailia East and Japan East. 


