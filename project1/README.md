# Load balancer

This is a IaC project to create a load balancer in front of a set of VMs, which are defined via packer.
Additionally, there's an example policy requiring all resources are created with at least a tag.

## Getting started

In order to start, make sure you have installed the following:

1. Azure CLI (Command Line Interface)
2. Packer
3. Terraform

## Instructions

Create the policy definition
`az policy definition create --name resources-tagging-policy --display-name "Tag EVERY resource Policy" --description "Tag EVERY resource policy" --rules tagging-rules.json --mode Indexed`

Actually activate the policy
`az policy assignment create --policy resources-tagging-policy`

Create the packer image for the VM   
`packer build server.json`

Create the entire infrastructure via Terraform: 
`terraform apply -var="username=gfalace" -var="password=Password-123" -var="location=East US" -var="prefix=udacity-p1" -var="poolsize=2"` 

after checking e.g. in the portal that everything went fine, you can destroy the infra:

`terraform apply -var="username=gfalace" -var="password=Password-123" -var="location=East US" -var="prefix=udacity-p1" -var="poolsize=2"`

## How to customize
The project can be customized especially by using variables in `vasr.tf` i.e. can increse/decrease the size of the "pool" of machines backing the Load Balancer. 

Also, additional rules could be added to the policy.
