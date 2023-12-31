# --- compute/main.tf ---

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "random_id" "dev_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "ec2_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "dev_node" {
  count         = var.instance_count # 1
  instance_type = var.instance_type  # t3.micro
  ami           = data.aws_ami.server_ami.id
  tags = {
    Name = "dev_node-${random_id.dev_node_id[count.index].dec}"
  }

  key_name = aws_key_pair.ec2_auth.id

  vpc_security_group_ids = var.public_sg
  subnet_id              = var.public_subnets[count.index]

  user_data = templatefile(var.user_data_path,
    {
      nodename    = "dev-${random_id.dev_node_id[count.index].dec}"
      db_endpoint = var.db_endpoint
      dbpass      = var.dbpassword
      dbname      = var.dbname
      dbuser      = var.dbuser
    }
  )

  root_block_device {
    volume_size = var.vol_size # 10
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("./ec2keypair")
    }
    script = "${path.root}/delay.sh"
  }
#   provisioner "local-exec" {
#     command = templatefile("${path.root}/scp_script.tpl",
#       {
#         nodeip   = self.public_ip
#         k3s_path = "${path.root}/../"
#         nodename = self.tags.Name
#       }
#     )
#   }
}

resource "aws_lb_target_group_attachment" "dev_tg_attach" {
  count            = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.dev_node[count.index].id
  port             = var.tg_port
}