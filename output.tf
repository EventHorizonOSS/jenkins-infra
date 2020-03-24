output "jankins-lab-key-pair-name" {
  description = "Jenkins lab key pair name"
  value       = aws_key_pair.jenkins-lab-key.key_name
}

output "jenkins-lab-instance-name" {
  description = "Jenkins lab instance name"
  value = aws_instance.jenkins-lab.tags.Name
}
