#!/bin/bash

REGION=sa-east-1
JENKINS_ADDRESS="jenkins2.lab.eventhorizon.com.br"
TERRAFORM=/opt/terraform-0.12.24/terraform

IP=$($TERRAFORM show | grep jenkins-lab-public-ip | cut -d = -f 2 | tr -d " " | tr -d '"')
printf "Jenkins public IP address: %s\n" "$IP"

printf "INFO: Stopping Jenkins ... "
if ssh -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key ubuntu@$JENKINS_ADDRESS "sudo docker-compose -f /jenkins/jenkins-infra/docker-compose.yml down" > /dev/null 2>&1
then
  printf "[DONE]\n"
else
  printf "[FAILED]\n"
  exit 0
fi

printf "INFO: Umounting Jenkins data volume ... "
if ssh -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key ubuntu@$JENKINS_ADDRESS "sudo umount /jenkins" > /dev/null 2>&1
then
  printf "[DONE]\n"
else
  printf "[FAILED]\n"
  exit 0
fi

printf "INFO: Destroying Jenkins infra ...\n"
$TERRAFORM destroy -var region="$REGION"

printf "[DONE]\n"
