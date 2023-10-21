variable "project" {
  type = string
}

variable "min_replicas" {
  type    = string
  default = "1"
}

variable "max_replicas" {
  type    = string
  default = null
}
