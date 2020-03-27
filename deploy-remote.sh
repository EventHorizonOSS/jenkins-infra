#!/bin/bash

# Set up Docker repsitory
sudo apt-get update
sudo apt-get install -yq \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
sudo apt-get -yq update
sudo apt-get -yq install docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker "$USER"
sudo newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Mount Jenkins data volume
sudo mkdir /jenkins
sudo chown -R ubuntu:ubuntu /jenkins
if ! mount | grep /jenkins > /dev/null 2>&1;
then
  sudo mount /dev/xvdb1 /jenkins
fi

sudo mount /dev/xvdb1 /jenkins

# Clone GitHub project
JENKINS_SRC=/jenkins/jenkins-infra
cd /jenkins
if [[ -d $JENKINS_SRC ]];
then
  cd $JENKINS_SRC
  git pull
else
  git clone https://github.com/EventHorizonOSS/jenkins-infra.git $JENKINS_SRC
fi

# Run Jenkins
docker-compose -f $JENKINS_SRC/docker-compose.yml up -d
