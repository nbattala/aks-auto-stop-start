# aks-auto-stop-start
Schedule automatic stop and start of Azure aks cluster using terraform

## Pre-requisites
Install Terraform

## Steps
1. create a tfvars file if necessary to override default terraform variables defined in variable.tf
2. terraform init
3. terraform plan -var-file=<tfvars file> -out my-tf.plan
4. terraform apply my-tf.plan
