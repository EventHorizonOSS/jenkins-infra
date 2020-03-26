provider "aws" {
  version = "~> 2.0"
  region  = var.region
  profile = "default"
}

terraform {
  backend "s3" {
    bucket = "jenkins-lab-bucket"
    key    = "terraform.tfstate"
    region = "sa-east-1"
  }
}

resource "aws_key_pair" "jenkins_lab_key" {
  key_name   = "jenkins2-lab-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKuT3dzjw/7gUkVdep4j70tiZgVsaTwhGXf84+XmsYF00YjUm4nMd7TXeXDBnl2S6sh506GjmycuQh/Fz2ytzBots2PEFz1KZVDV+fjN+ihNdIg7iUglD4yycxsyqR7fkbHIFR8oVYjBPU419rGPsJ9kW4jqL26M5Q3BD6T7ry8OgBMk80cG353e/24GLezt5CY/aUl+erUObBY5Vj2PeUnuhchOwKV5AG0zMZeaCqZ187+kt8ZroflimOkTh0PDlOsNwGS43Lndzzv7MkQqjhWQVQvLYZKWbz5s5XYBolZ8qdbdR0QGmtZo60sK5HJxJaX4ViM8wUCG2IYbLaJd0dWQuekKjRE2ljKT4s6V9x0QO1wwBF57Q6AnU6qocB6BDT9ZICCIhtvkG5yuLk962hUpX+H2MD9xQA/DWOLB9Kpl+yTvM3xjnRjQ4phbFU0DhZPG+jSPxV/Vc0f+cQUseW9AuS2gpWnHuI3hAh5/01L3+dg7CvyHganSuDeWdux1GjwSU2OC/lQOKMs6O29z1vjzXZybxbOJrhwVQE/xJlaetbLWRGjiuwbO3JfhQGOIxRFAcTj+ZtVOEzIaiGN8/kUBsSI35yId9dsXuCTKy8Lw1oMw9doHiXCxXx4Pj2EJfVALeIwI00Aqo3mkahJ2nocD+1788a4H9NCn/ZSz9nLw== jenkins-lab-key"
}

resource "aws_instance" "jenkins_lab_instance" {
  ami                    = data.aws_ami.ubuntu.id
  availability_zone      = "sa-east-1a"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.jenkins_lab_key.key_name
  vpc_security_group_ids = ["sg-0ac6efa178014afad"]
  subnet_id              = "subnet-019bfffc20f358108"

  tags = {
    Name = "jenkins2-lab"
  }

  volume_tags = {
    Name = "jenkins2-lab-volume"
  }
}

resource "aws_volume_attachment" "jenkins2_lab_volume_attachment" {
  device_name = "/dev/sda2"
  volume_id   = "vol-090c23ad9c73f038c"
  instance_id = aws_instance.jenkins_lab_instance.id
}

resource "aws_eip" "jenkins_lab_eip" {
  instance = aws_instance.jenkins_lab_instance.id
  associate_with_private_ip = aws_instance.jenkins_lab_instance.private_ip
  vpc      = true
  tags = {
    Name = "jenkins2-lab-elastic-ip"
  }
}

resource "aws_route53_record" "jenkins_private_dns" {
  zone_id = data.aws_route53_zone.jenkins_route53_zone.zone_id
  name    = "jenkins2-int"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.jenkins_lab_eip.private_ip]
}

resource "aws_route53_record" "jenkins_public_dns" {
  zone_id = data.aws_route53_zone.jenkins_route53_zone.zone_id
  name    = "jenkins2"
  type    = "A"
  ttl     = "60"
  records = [aws_eip.jenkins_lab_eip.public_ip]
}
