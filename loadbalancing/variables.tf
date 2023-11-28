# --- loadbalancing/variables.tf ---

variable "public_subnets" {}

variable "public_sg" {}

variable "idle_timeout" {}

variable "tg_port" {}

variable "dev_vpc" {}

variable "lb_healthy_threshold" {}

variable "lb_unhealthy_threshold" {}

variable "lb_timeout" {}

variable "lb_interval" {}

variable "tg_protocol" {}

variable "listener_port" {}

variable "listener_protocol" {}