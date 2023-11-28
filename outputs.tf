# --- root\outputs.tf ---

output "Load_balancer_endpoint" {
  value = module.loadbalancing.lb_endpoint
}

output "instances" {
  value     = { for i in module.compute.instance : i.tags.Name => i.public_ip }
  sensitive = true
}

output "instance_tg_port" {
  value     = { for i in module.compute.instance : i.tags.Name => "${i.public_ip}:${module.compute.instance_tg_port}" }
  sensitive = true
}