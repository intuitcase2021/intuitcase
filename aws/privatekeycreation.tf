resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh-key" {
  key_name   = var.key_name
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { 
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./demo-ssh-key.pem && sleep 5 && chmod 400 demo-ssh-key.pem && ssh-add demo-ssh-key.pem"
  }

}