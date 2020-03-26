output "jankins-lab-key-pair-name" {
  description = "Jenkins lab key pair name"
  value       = aws_key_pair.jenkins_lab_key.key_name
}

output "jenkins-lab-instance-name" {
  description = "Jenkins lab instance name"
  value = aws_instance.jenkins_lab_instance.tags.Name
}

output "jenkins-lab-instance-id" {
  description = "Jenkins lab instance ID"
  value = aws_instance.jenkins_lab_instance.id
}

output "jenkins-lab-private-ip" {
  description = "Jenkins lab instance private IP"
  value = aws_eip.jenkins_lab_eip.private_ip
}

output "jenkins-lab-public-ip" {
  description = "Jenkins lab instance public IP"
  value = aws_eip.jenkins_lab_eip.public_ip
}
