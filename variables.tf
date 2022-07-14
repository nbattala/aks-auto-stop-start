## Global
variable client_id {
  default = ""
}
variable client_secret {
  default = ""
}

variable subscription_id {
  default = ""
}
variable tenant_id {
  default = ""
}

variable tags {
  default = null
}

variable "resource_group_name" {
  type    = string
  default = null
  description = "Name of pre-exising resource group. Leave blank to have one created"
}

variable "location" {
  description = "The Azure Region to provision all resources in this script"
  default     = "eastus"
}

variable "automation_account_name" {
  description = "Name of the automation account to be created"
  type        = string
  default     = "my-automation-account"
}

variable "automation_account_identity" {
  description = "Type of identity that should be enabled for the automation account"
  type        = string
  default     = "SystemAssigned"
}

variable "automation_account_role" {
  description = "role of automation account in the subscription"
  type        = string
  default     = "Contributor"
}

variable "automation_account_sku" {
  description = "sku of the automation account to be created"
  type        = string
  default     = "Basic"
}

variable "automation_runbook" {
  description = "name of the runbook inside the automation account"
  type        = string
  default     = "aks-stop-start"
}

variable "log_verbose" {
  description = "toggle verbose level of automation runbook"
  type        = bool
  default     = true
}

variable  "log_progress" {
  description = "progress of log of automation runbook"
  type        = bool
  default     = true
}

variable  "runbook_description" {
  default     = "This is a runbook used to automate stop and start of aks cluster to save costs"
}

variable  "runbook_type" {
  description =  "the type of runbook"
  type        = string
  default     = "PowerShell"
}

variable   "runbook_filename" {
  description = "filename of runbook terraform root directory"
  type        = string
  default     = "stop-start-aks-runbook.ps1"
}

variable  "schedule_name" {
  description = "name of the automation schedule"
  type        = string
  default     = "stop-aks-cluster"
}

variable  "schedule_frequency" {
  description = "frequency of the automation schedule"
  type        = string
  default     = "Day"
}

variable "schedule_interval" {
  description = "frequency interval of the automation schedule"
  type        = string
  default     = "1"
}

variable "schedule_timezome" {
  description = "timezone of the automation schedule"
  type        = string
  default     = "America/Los_Angeles"
}

variable "schedule_start_time" {
  description = "start time of the automation schedule"
  type        = string
  default     = "2022-07-14T19:00:00+07:00"
}

variable "job_parameters" {
  description = "parameters for the job scheduled. aksclustername should be the cluster we want to start/stop aksresourcegroupname is the resourcegroup name where the cluster is present. operation can only be either 'Start' or 'Stop'"
  type        = map
  default     = {
    aksclustername         = null
    aksresourcegroupname   = null
    operation              = null
  }

}