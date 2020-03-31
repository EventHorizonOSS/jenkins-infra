#!/bin/bash

if [[  $__DEPLOY__ != true ]];
then
  CMD_NAME="deploy"

  deploy_usage() {
    printf "\n"

    printf "NAME\n"
    printf "%7s %s\n" "" "$CMD_NAME"

    printf "\n"
    printf "SYNOPSIS\n"
    printf "%7s %s\n" "" "$CMD_NAME"
    printf "%7s %s\n" "" "[--cert-dir]"

    printf "\n"
    printf "DESCRIPTION\n"
    printf "%7s %s\n" "" "Deploy the Jenkins infra strucuture to AWS through Terraform."

    printf "\n"
    printf "PARAMETERS\n"

    printf "%7s %s\n\n" "" "--cert-dir (string)"
    printf "%7s %s\n" "" "Specify the directory where the Jenkins SSL certificate and  private  key"
    printf "%7s %s\n" "" "files are stored."
    printf "\n"

    printf "\n"
    exit 0
  }

  parse_deploy_args() {
    while [[ $# -gt 0 ]]
    do
      key="$1"
      case $key in
        --cert-dir)
          OPT_CERT_DIR=$2
          shift
          shift
          ;;
        help)
          deploy_usage
          ;;
        *)
          deploy_usage
          ;;
      esac
    done
  }

  print_deploy_args() {
    printf "\n"
    printf "ARGUMENTS\n"
    printf "%10s %-30s %s\n" "" "Certificate directory: " "$OPT_CERT_DIR"
    printf "\n"
  }

  terraform_deploy() {
    printf "Deploying Jenkins infra structure to AWS through Terraform ...\n\n"
    if [[ $OPT_DRY_RUN == true ]];
    then
      $TERRAFORM plan -var region="$OPT_REGION"
      exit 0
    else
      $TERRAFORM apply -var region="$OPT_REGION"
    fi

    printf "Deploying Jenkins infra structure to AWS through Terraform ... [DONE]\n"
  }

  setup_jenkins_ssl() {
    CERT_FILE="$OPT_CERT_DIR/fullchain.pem"
    KEY_FILE="$OPT_CERT_DIR/privkey.pem"
    printf "INFO: Creating certificate destination folder on Jenkins instance ... "
    if ssh -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key ubuntu@"$JENKINS_ADDRESS" "sudo mkdir -p /jenkins/certs && sudo chown -R ubuntu:ubuntu /jenkins" > /dev/null 2>&1
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
    if scp -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key "$CERT_FILE" ubuntu@"$JENKINS_ADDRESS":/jenkins/certs/"$JENKINS_ADDRESS".crt > /dev/null 2>&1
    then
      printf "[DONE]\n"
    else
      printf "[FAILED]\n"
      exit 0
    fi

    printf "Copying SSL private key to Jenkins instance ... "
    if scp -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key "$KEY_FILE" ubuntu@"$JENKINS_ADDRESS":/jenkins/certs/"$JENKINS_ADDRESS".key > /dev/null 2>&1
    then
      printf "[DONE]\n"
    else
      printf "[FAILED]\n"
      exit 0
    fi
  }

  wait_for_jenkins_instance() {
    COUNT=20
    TIMEOUT=10
    INSTANCE_OK=false
    IP=$($TERRAFORM show | grep jenkins-lab-public-ip | cut -d = -f 2 | sed -e 's/[[:space:]]//')
    printf "Jenkins public IP address: %s\n" "$IP"
    while [[ $COUNT -gt 0 ]]
    do
      printf "Wating for Jenkins instance ... "
      if ping -c 1 "$JENKINS_ADDRESS" -W $TIMEOUT > /dev/null 2>&1
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
      printf "INFO: Jenkins isntance %s is up and running\n" "$JENKINS_ADDRESS"
    else
      printf "ERROR: Timeout while waiting for Jenkins instance\n"
      printf "NOTE: Check the instance security group and grant that this machine IP is allowed to ping\n"
      exit 0
    fi
  }

  execute_remote_deploy() {
    ssh -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key ubuntu@"$JENKINS_ADDRESS" 'bash -s' < ./deploy-remote.sh
  }

  execute_deploy_command() {
    printf "Executing deploy command ...\n"
    terraform_deploy
    wait_for_jenkins_instance
    execute_remote_deploy
    printf "Done\n"
  }

  readonly __DEPLOY__=true
fi
