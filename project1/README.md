# Load balancer

## Overview
The purpose of these project is to create a load-balanced web server, using Terraform to provision cloud resources and Packer as a server templating.
More specifically, a load balancer is defined, which sits in front of a pool of virtual machines. Virtual machines will be defined via Packer and will be grouped into an availability set. 
Additionally, there's an example policy requiring that all resources are created with at least a tag.

## Getting started

In order to start, make sure you have installed the following:

1. Azure CLI (Command Line Interface)
2. Packer
3. Terraform

Note: make sure to successfully run `az login` so that you don't have to write credentials in any of these files. 

## Instructions

Create the policy definition
```
az policy definition create --name resources-tagging-policy --display-name "Tag EVERY resource Policy" --description "Tag EVERY resource policy" --rules tagging-rules.json --mode Indexed
```

Actually activate the policy
```
az policy assignment create --policy resources-tagging-policy
```

Test that the policy has been assigned correctly
```
az policy assignment list
```
Will show something like the following:
![cli output](/project1/images/Screenshot_AZ_policy.png)

Create the packer image for the VM   
```
packer build server.json
```

Initialize Terraform. Go in the same folder as the `main.tf` file and run:
```
terraform init
```

Create the entire infrastructure, executing the Terraform code: 
```
terraform apply -var="username=gfalace" -var="password=Password-123" -var="location=East US" -var="prefix=udacity-p1" -var="poolsize=2"
```
Output will look like this:
![terraform apply output](/project1/images/terraform_apply.png)


after checking e.g. in the portal that everything went fine, you can destroy the infra:
```
terraform destroy -var="username=gfalace" -var="password=Password-123" -var="location=East US" -var="prefix=udacity-p1" -var="poolsize=2"
```
which will remove all the resources defined in the terraform code, if found.
Output will look like this:
![terraform destroy output](/project1/images/terraform_destroy.png)

Note: since the `vars.tf` file contains default values for all variables, the commands can be ran without any `-var="..."` option. Just as `terraform apply` and `terraform destroy`. 


## How to customize
The project can be customized especially by using variables in `vasr.tf`. Here is how to use them:
* Variable `poolsize` is the number of VM backing the LB. Must be >= 2 and <5 (is enforced via validation).
* Variable `location` is the Azure region (e.g. `East US`) where the resources will be created.
* Variable `prefix` is the common prefix that'll be given all resources.  
* Variables `username` and `password` are the credentials that will be set up for the created virtual machines.

Also, additional rules could be added to the policy.

## >>> Question about review comment

Sorry for writing in the readme, couldn't find a way to ask in clarifications about comments.

Regarding the NSG I seem to understand that a default "deny all" rule -- called `DenyAllInBound` -- should be there, at least according to the documentation (in those links) and to what I see in the portal after creating the rule to allow intra-subnet traffic (see pic below).

![NSG rules](/project1/images/NSG_Rules.png)

Then why the rubric asks to *“denies inbound traffic from the internet”*? 

I have the feeling I'm missing something here.

Could you please give me more feedback about this? 

Thanks!! 
