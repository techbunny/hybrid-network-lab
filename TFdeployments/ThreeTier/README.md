# Introduction 
This repro contains four separate deployments to account for differences in lifecycle for parts of the infrastructure and they should be deployed in the following order:

1. CoreInfra - Deploys the virtual network for both regions with default subnets, peers the VNETs, creates proximity placement groups for Zone 1 and Zone 2, bastion host, an external load balancer used only for outbound access to the internet and the Desired State Configuration services with configurations. 

After this deployment is complete, it is necessary to navigate to the DSC state configuration in the Azure Portal and compile the configurations for use by the VM deployments later.

2. DomainControllers - Deploys two domain controllers in an availability set in Region 1 only (at this time)  These VMs will be added to the backend pool of the outbound load balancer, connect to the DSC service and configure the domain as specified in the DSC Configuration module in main.tf.  The DNS name for the domain is an example only.

3. FrontEnd - Deploys web and app servers in Region 1 only (at this time) in their own subnets. Each VM will be added to the backend pool for the outbound load balancer, are split between two proximity placement groups and joins all VMs to the domain.  The app servers run a basic configuration to attached the data disks within the OS. Two types of web servers are deployed using VMs and VMSS, all instances install a basic IIS configuration and join a webserver pool on an internal load balancer. 

4. BackEnd - Deploys VM for SQL services in a similar manner as the FrontEnd configuration, but this deployment does not yet have DSC configurations. 

## Notes

All deployments will to have a terraform.tfvars file or other mechanism to provide the tenant and subscription IDs, as well as the default admin password for VMs.  



