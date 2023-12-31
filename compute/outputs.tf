# --- compute\outputs.tf ---

output "instance" {
  value     = aws_instance.dev_node[*]
  sensitive = true
}

output "instance_tg_port" {
  value = aws_lb_target_group_attachment.dev_tg_attach[0].port
}