#!/bin/bash

JENKINS_ADDRESS="jenkins2.lab.eventhorizon.com.br"
TERRAFORM=/opt/terraform-0.12.24/terraform
REGION=
CERT_DIR=
DRY_RUN=false

usage() {
  printf "\n"

  printf "NAME\n"
  printf "%10s %-36s %s\n" "" "$0"

  printf "DESCRIPTION\n"
  printf "%10s %-36s %s\n" "" "$0 [options]"

  printf "OPTIONS\n"
  printf "%10s %-36s %s\n" "-h" "--help" "Help"
  printf "%10s %-36s %s\n" "-r" "--region" "AWS region"
  printf "%10s %-36s %s\n" "" "--cert-dir" "Directory where the SS certificate and private key are located"
  printf "%10s %-36s %s\n" "-n" "--dry-run" "Dry run"

  printf "\n"
  exit 0
}

check_args() {
  if [[ -z $REGION ]];
  then
    usage
  fi
  if [[ -z $CERT_DIR ]];
  then
    printf "WARNING: Certificate directory was not set, will assume the current working directory"
    CERT_DIR=$(pwd)
  fi
}

print_args() {
  printf "\n"
  printf "ARGS\n"
  printf "%10s %-30s %s\n" "" "Region: " "$REGION"
  printf "%10s %-30s %s\n" "" "Certificate directory: " "$CERT_DIR"
  printf "%10s %-30s %s\n" "" "Dry run: " "$DRY_RUN"
  printf "\n"
}

# Parse args
POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    -h|--help)
      usage
      ;;
    -r|--region)
      REGION="$2"
      shift
      shift
      ;;
    --cert-dir)
      CERT_DIR="$2"
      shift
      shift
      ;;
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      usage
      ;;
  esac
done
set -- "${POSITIONAL[@]}"

check_args

print_args

# Deploy infra via Terraform to AWS
printf "Deploying Jenkins infra structure to AWS through Terraform ...\n"
if [[ $DRY_RUN == true ]];
then
  $TERRAFORM plan -var region="$REGION"
  exit 0
else
  $TERRAFORM apply -var region="$REGION"
fi

# Wait for Jenkins instance to be up
COUNT=20
TIMEOUT=10
INSTANCE_OK=false
IP=$($TERRAFORM show | grep jenkins-lab-public-ip | cut -d = -f 2 | sed -e 's/[[:space:]]//')
printf "Jenkins public IP address: %s" "$IP"
while [[ $COUNT -gt 0 ]]
do
  printf "Wating for Jenkins instance to be up ... "
  if ping -c 1 $JENKINS_ADDRESS -W $TIMEOUT > /dev/null 2>&1
  then
    printf "[OK]\n"
    INSTANCE_OK=true
    break
  else
    # shellcheck disable=SC2059
    printf "[$COUNT]\n"
    COUNT=$((COUNT-1))
  fi
done
if [[ $INSTANCE_OK == true ]];
then
  printf "INFO: Jenkins isntance %s is up and running\n" $JENKINS_ADDRESS
else
  printf "ERROR: Timeout while waiting for Jenkins instance to be up\n"
  printf "NOTE: Check the instance security group and grant that this machine IP is allowed to ping\n"
  exit 0
fi

# Copy SSL certificate to Jenkins instance
CERT_FILE="$CERT_DIR/fullchain.pem"
KEY_FILE="$CERT_DIR/privkey.pem"
printf "INFO: Creating certificate destination folder on Jenkins instance ... "
if ssh -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key ubuntu@$JENKINS_ADDRESS "sudo mkdir -p /jenkins/certs && sudo chown -R ubuntu:ubuntu /jenkins" > /dev/null 2>&1
then
  printf "[DONE]\n"
else
  printf "[FAILED]\n"
  exit 0
fi

printf "INFO: SSL certificate file: %s " "$CERT_FILE"
if [[ -f $CERT_FILE ]];
then
  printf "[OK]\n"
else
  printf "[NOT FOUND]\n"
  exit 0
fi

printf "INFO: SSL private key file: %s " "$KEY_FILE"
if [[ -f $KEY_FILE ]];
then
  printf "[OK]\n"
else
  printf "[NOT FOUND]\n"
  exit 0
fi

printf "Copying SSL certificate to Jenkins instance ... "
if scp -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key "$CERT_FILE" ubuntu@$JENKINS_ADDRESS:/jenkins/certs/$JENKINS_ADDRESS.crt > /dev/null 2>&1
then
  printf "[DONE]\n"
else
  printf "[FAILED]\n"
  exit 0
fi

printf "Copying SSL private key to Jenkins instance ... "
if scp -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key "$KEY_FILE" ubuntu@$JENKINS_ADDRESS:/jenkins/certs/$JENKINS_ADDRESS.key > /dev/null 2>&1
then
  printf "[DONE]\n"
else
  printf "[FAILED]\n"
  exit 0
fi

# Run the remote part of deploy
ssh -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key ubuntu@$JENKINS_ADDRESS 'bash -s' < ./deploy-remote.sh

printf "\nFinished\n\n"
