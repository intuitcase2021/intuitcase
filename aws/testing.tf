

resource "aws_instance" "demo-private-instance" {
  ami                         = var.ami
  availability_zone           = var.availability_zones[0]
  ebs_optimized               = var.ebs_optimized
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = aws_subnet.privateSN[0].id
  vpc_security_group_ids      = ["${aws_security_group.private-SG.id}"]
  associate_public_ip_address = false

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -e 'private_ip=${aws_instance.demo-private-instance.private_ip}' inventory.yml && sleep 240 && ansible-playbook -i ./hosts install_apache.yml"
  }

  tags = merge(
    {
      Name        = "demo-private-instance",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}
