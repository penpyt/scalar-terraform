variable "base" {
  default     = "default"
  description = "The base of Cassandra cluster"
}

variable "network" {
  type        = map
  description = "The network settings of Cassandra cluster"
}

variable "cassandra" {
  type        = map
  default     = {}
  description = "The custom settings of Cassandra cluster"
}

variable "cassy" {
  type        = map
  default     = {}
  description = "The custom settings of Cassy resources"
}

variable "reaper" {
  type        = map
  default     = {}
  description = "The custom settings of Reaper resources"
}
