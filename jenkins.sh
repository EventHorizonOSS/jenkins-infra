#!/bin/bash

# General information
VERSION="1.0.0-RC1"
RESOURCES="./"
JENKINS_ADDRESS="jenkins2.lab.eventhorizon.com.br"
TERRAFORM=/opt/terraform-0.12.24/terraform

# Defaults
DEFAULT_DRY_RUN=false
DEFAULT_REGION=sa-east-1
DEFAULT_DRY_RUN=false

# Options, command and command parameters
OPT_DRY_RUN=$DEFAULT_DRY_RUN
OPT_REGION=
CMD=

. ${RESOURCES}/deploy.sh || exit 1
. ${RESOURCES}/destroy.sh || exit 1
. ${RESOURCES}/restart.sh || exit 1
. ${RESOURCES}/start.sh || exit 1
. ${RESOURCES}/stop.sh || exit 1

usage() {
  printf "\n"

  printf "NAME\n"
  printf "%7s %s\n" "" "$0"

  printf "\n"
  printf "SYNOPSIS\n"
  printf "%7s %s\n" "" "$0 [options] <command> [parameters]"

  printf "\n"
  printf "DESCRIPTION\n"
  printf "%7s %s\n" "" "The EventHorizon Jenkins tool, to help on many tasks like deploy,"
  printf "%7s %s\n" "" "destroy and other tasks related to Jenkins service."

  printf "\n"
  printf "OPTIONS\n"

  printf "%7s %s\n\n" "" "--help (string)"
  printf "%7s %s\n" "" "Prints this help."
  printf "\n"

  printf "%7s %s\n\n" "" "--dry-run (boolean)"
  printf "%7s %s\n" "" "Default: false"
  printf "%7s %s\n" "" "Set the dry run to true."
  printf "\n"

  printf "%7s %s\n\n" "" "--region (string)"
  printf "%7s %s\n" "" "Default: sa-east-1"
  printf "%7s %s\n" "" "Specify the AWS region to execute the command."
  printf "\n"

  printf "%7s %s\n\n" "" "--version"
  printf "%7s %s\n" "" "Prints the version of this tool."
  printf "\n"

  printf "\n"
  printf "COMMANDS\n"
  printf "%7s %s\n\n" ""  "deploy"
  printf "%7s %s\n\n" ""  "destroy"
  printf "%7s %s\n\n" ""  "restart"
  printf "%7s %s\n\n" ""  "start"
  printf "%7s %s\n\n" ""  "stop"

  printf "\n"
  exit 0
}

print_version() {
  printf "%s\n" "$VERSION"
  exit 0
}

print_options() {
  printf "\n"
  printf "OPTIONS\n"
  printf "%10s %-30s %s\n" "" "Jenkins address: " "$JENKINS_ADDRESS"
  printf "%10s %-30s %s\n" "" "Region: " "$OPT_REGION"
  printf "%10s %-30s %s\n" "" "Certificate directory: " "$OPT_CERT_DIR"
  printf "%10s %-30s %s\n" "" "Dry run: " "$OPT_DRY_RUN"
  printf "\n"
}

check_options() {
  if [[ -z $OPT_REGION ]];
  then
    printf "WARNING: Region was not specified, will use the default region: %s\n" "$DEFAULT_REGION"
    OPT_REGION=$DEFAULT_REGION
  fi
  if [[ -z $OPT_CERT_DIR ]];
  then
    printf "WARNING: Certificate directory was not set, will assume the current working directory: %s\n" "$(pwd)"
    OPT_CERT_DIR=$(pwd)
  fi
}

parse_args() {
  # Check the number of arguments
  if [[ $# -le 0 ]];
  then
    usage
  fi

  # Parse arguments
  POSITIONAL=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    case $key in
      --dry-run)
        OPT_DRY_RUN=true
        shift
        ;;
      --help)
        usage
        ;;
      --region)
        OPT_REGION=$2
        shift
        shift
        ;;
      --version)
        print_version
        ;;
      deploy)
        CMD=deploy
        shift
        parse_deploy_args "$@"
        break
        ;;
      destroy)
        CMD=destroy
        shift
        parse_destroy_args "$@"
        break
        ;;
      restart)
        CMD=restart
        shift
        parse_restart_args "$@"
        break
        ;;
      start)
        CMD=start
        shift
        parse_start_args "$@"
        break
        ;;
      stop)
        CMD=stop
        shift
        parse_stop_args "$@"
        break
        ;;
      *)
        usage
        ;;
    esac
  done
  set -- "${POSITIONAL[@]}"
}

# Parse arguments
parse_args "$@"

# Check options
check_options

# Print data
print_options

# Eecute command
case $CMD in
  deploy)
    print_deploy_args
    execute_deploy_command
    ;;
  destroy)
    execute_destroy_command
    ;;
  restart)
    execute_restart_command
    ;;
  start)
    execute_start_command
    ;;
  stop)
    execute_stop_command
    ;;
  *)
    usage
    ;;
esac

printf "Finished [SUCCESS]\n\n"
exit 0
