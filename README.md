# aks-auto-stop-start
Schedule automatic stop and start of Azure aks cluster using terraform

## Pre-requisites
1. Terraform
2. Owner privileges on Azure subscription

## Steps
1. create a tfvars file to override the default terraform variables defined in variable.tf. The only variable you would typically need to override are listed in the sample below. Please look into variables.tf for all the variables that can be overridden. 

   Sample - custom_variables.tfvars
      ```bash
      job_parameters = {
      aksclustername         = "my-aks"
      aksresourcegroupname   = "my-rg"
      operation              = "Stop" 
      }
      
      schedule_name = "stop-aks-cluster"
      
      schedule_frequency = "Day"
      
      schedule_interval = "1"
      
      schedule_timezone = "America/Los_Angeles"
      
      schedule_start_time = "2022-07-14T19:00:00+07:00"
      ```
    
2. terraform init
3. terraform plan -var-file=custom_variables.tfvars -out my-tf.plan
4. terraform apply my-tf.plan
