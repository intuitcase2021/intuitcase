

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
    command = "cd ../ansible && ansible-playbook -i /usr/local/etc/ansible/hosts install_apache.yml"
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

//resource "aws_network_interface_sg_attachment" "private-SG" {
//  security_group_id    = aws_security_group.private-SG.id
//  network_interface_id = aws_instance.demo-private-instance.primary_network_interface_id
//}