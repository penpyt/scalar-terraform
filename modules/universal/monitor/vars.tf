variable "bastion_host_ip" {
  description = "The Public IP address to the Bastion Host"
}

variable "private_key_path" {
  description = "The path to a private key (.pem) file for auth"
}

variable "user_name" {
  description = "The user of the remote instance to provision"
}

variable "triggers" {
  description = "A trigger to initiate provisioning"
  default     = []
}

variable "host_list" {
  default     = []
  description = "A list of ScalarDL hosts (IP or DNS) to provision"
}

variable "provision_count" {
  description = "The number of resources to provision"
}

variable "slack_webhook_url" {
}

variable "scalardl_blue_resource_count" {
}

variable "scalardl_green_resource_count" {
}

variable "cassandra_resource_count" {
}

variable "network_id" {
}

variable "network_name" {
}

variable "replication_factor" {
  default     = 3
  description = "Set the replication factor for schema"
}

variable "enable_tdagent" {
  default     = true
  description = "A flag to install td-agent that forwards logs to the monitor host"
}

variable "internal_root_dns" {
  description = "Internal root dns"
}