#!/bin/bash

if [[  $__DESTROY__ != true ]];
then
  parse_destroy_args() {
    printf "Destroy n args: %s\n" "$#"
    printf "Destroy args: %s\n" "$@"
  }

  execute_destroy_command() {
    printf "Executing destroy command ...\n"

    IP=$($TERRAFORM show | grep jenkins-lab-public-ip | cut -d = -f 2 | tr -d " " | tr -d '"')
    printf "Jenkins public IP address: %s\n" "$IP"

    if [[ $OPT_DRY_RUN == true ]];
    then
      $TERRAFORM plan -destroy -var region="$OPT_REGION"
      exit 0
    else
      printf "INFO: Stopping Jenkins ... "
      if ssh -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key ubuntu@$JENKINS_ADDRESS "sudo docker-compose -f /jenkins/jenkins-infra/docker-compose.yml down" > /dev/null 2>&1
      then
        printf "[DONE]\n"
      else
        printf "[FAILED]\n"
      #  exit 0
      fi

      printf "INFO: Umounting Jenkins data volume ... "
      if ssh -o "StrictHostKeyChecking no" -i ~/Google\ Drive/Workspace/AWS/ec2-keys/jenkins2-lab-sa-east-1.key ubuntu@$JENKINS_ADDRESS "sudo umount /jenkins" > /dev/null 2>&1
      then
        printf "[DONE]\n"
      else
        printf "[FAILED]\n"
      #  exit 0
      fi

      printf "INFO: Destroying Jenkins infra ...\n"
      $TERRAFORM destroy -var region="$OPT_REGION"
    fi

    printf "Done\n"
  }

  readonly __DESTROY__=true
fi
