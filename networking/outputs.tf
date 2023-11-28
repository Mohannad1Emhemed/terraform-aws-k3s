# --- networking/outpurs.tf ---

output "vpc_id" {
  value = aws_vpc.dev_vpc
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.dev_rds_subnetgroup.*.name
}

output "db_security_group" {
  value = [aws_security_group.dev_sg["rds"].id]
}

output "lb_security_group" {
  value = [aws_security_group.dev_sg["public"].id]
}

output "lb_subnet_group_name" {
  value = aws_subnet.dev_public_subnet.*.id
}

output "public_subnets" {
  value = aws_subnet.dev_public_subnet.*.id
}

output "public_sg" {
  value = [aws_security_group.dev_sg["public"].id]

}