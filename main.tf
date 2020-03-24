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

resource "aws_key_pair" "jenkins-lab-key" {
  key_name   = "jenkins-lab-key2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCDU8BeoVmIrzHXlQTpRS+aWswV4ZwniJx7SXR6LXLdcrqP8c42QPHYI2ka1nQdA8syLcM63tRzaBow5EsPXuIOWg0nz9UYafCEP17wRLoYmAMeGDZlOhulE2kRCp8UjmlXuCno/IT7CN57YTbW3oZE5WAAAJOm3rVTx/yUUQ8IJFD17I3C9w2b6kX3O9mtuztdbjBHLVZ/I4g74sIGgz2bLy3GrkQORqbNQQfpG7T2sdRgztZXLTiaT5UhNErVXTE6U0OTn5FVWri3BUc8XYIk74QN0AWcAYWHCxxAPqjqrdfWrERHwPulZSAHrVDicK4Y9mUjoKKnBuxUcTabUJ61 jenkins-lab-key"
}

resource "aws_instance" "jenkins-lab" {
  ami                    = data.aws_ami.ubuntu.id
  availability_zone      = "sa-east-1a"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.jenkins-lab-key.key_name
  vpc_security_group_ids = ["sg-0ac6efa178014afad"]
  subnet_id              = "subnet-019bfffc20f358108"

  tags = {
    Name = "jenkins-lab"
  }

  volume_tags = {
    Name = "jenkins-lab-volume"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }
}
