provider "aws" {
  version = "~> 2.0"
  region  = var.region
  profile = "default"
}

terraform {
  backend "s3" {
    bucket = "jenkins-lab-bucket"
    key    = "terraform/terraform.tfstate"
    region = "sa-east-1"
  }
}

resource "aws_key_pair" "jenkins_lab_key" {
  key_name   = "jenkins2-lab-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhMX/ElhWJPlo40LQjqYbJ1aCsGFlg1XmXbvYNfsQayelyav3VIoyy0glIIQH/NXmQO6XzSq19w2xmNwWTj5kPbJoLiAkinZhkXBtVVjzfAPo0W91rhLJ225YZDLm4hDblGeEJtUpvrdbaTnNNcStCFAdpPMNAOkczDkkhE00XgiyGclC1eSaQWmOYwlaFnmHQAx0KTqLpv+BTfASu0WeS+9U9xk6NA5sUamLEvunuza7JN5PVlFlB8AwPziVGdIaw+oUh6eZIosq54PMsV8+ktNxjIb5oYpz8Ga3VOdxh3R/4CBmtPhFJBxEL1/NGXlyQplKYF8/5nXzmW1NC/pPXenhw33bxs902PPPki7U1yiNuNucOooNg5GcSpYxTBXovaaZhKCTM0jk2ZPWvWVytBlyISYT30cLTIgtYr7NcYfXUThonH0X3U3X+CZdXVReZicJIVKytnwCneBmZh8gpLattJwZLj06ZLTMzyYSVVIo7+CfgZ64hJMIWsM8/NXIzy5CJd/SujTHY9jbLxekgd0pdcr518EmbtMugEBduSuCVd6YIRvxPm3W+wbQDQ23czILhngyLCWSUaAUWLysqp11/ElS5SxPoeQv5H1SzAMvk+9wrPkcf3Ba2SNgW00+CVASXWGc5gbQHkXuSJHCuvLwEK3pxjeJPuHgN95UTnw== jankins2-lab-key"
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
