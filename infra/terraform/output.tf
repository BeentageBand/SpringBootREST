output "private-key" {
  value = tls_private_key.private-key.private_key_pem
  sensitive = true
}

output "public-key-openssh" {
  value = tls_private_key.private-key.public_key_openssh
}

output "jenkins-0" {
  value = aws_instance.jenkins.*.public_ip[0]
}

output "jenkins-1" {
  value = aws_instance.jenkins.*.public_ip[1]
}
