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
  printf "%7s %-36s %s\n" "" "$0 [options] <command> [parameters]"

  printf "\n"
  printf "DESCRIPTION\n"
  printf "%7s %s\n" "" "The EventHorizon Jenkins tool, to help on many tasks like deploy,"
  printf "%7s %s\n" "" "destroy and other tasks related to Jenkins service."

  printf "\n"
  printf "OPTIONS\n"
  printf "%10s %-20s %s\n" "-h" "--help"      "Prints this help"
  printf "%10s %-20s %s\n" "-n" "--dry-run"   "Dry run"
  printf "%10s %-20s %s\n" "-r" "--region"    "Specify the AWS region to execute the command"
  printf "%10s %-20s %s\n" "-v" "--version"   "Prints the version of this tool"

  printf "\n"
  printf "COMMANDS\n"
  printf "%7s %s\n" ""  "deploy"
  printf "%7s %s\n" ""  "destroy"
  printf "%7s %s\n" ""  "restart"
  printf "%7s %s\n" ""  "start"
  printf "%7s %s\n" ""  "stop"

  printf "\n"
  exit 0
}

print_version() {
  printf "%s\n" "$VERSION"
  exit 0
}

print_data() {
  printf "\n"
  printf "OPTIONS\n"
  printf "%10s %-20s %s\n" "" "Jenkins address: " "$JENKINS_ADDRESS"
  printf "%10s %-20s %s\n" "" "Region: " "$OPT_REGION"
  printf "%10s %-20s %s\n" "" "Certificate directory: " "$OPT_CERT_DIR"
  printf "%10s %-20s %s\n" "" "Dry run: " "$OPT_DRY_RUN"
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
      -n|--dry-run)
        OPT_DRY_RUN=true
        shift
        ;;
      -h|--help)
        usage
        ;;
      -r|--region)
        OPT_REGION=$2
        shift
        shift
        ;;
      -v|--version)
        print_version
        ;;
      deploy)
        CMD=deploy
        shift
        parse_deploy_args "$@"
        ;;
      destroy)
        CMD=destroy
        shift
        parse_destroy_args "$@"
        ;;
      restart)
        CMD=restart
        shift
        parse_restart_args "$@"
        ;;
      start)
        CMD=start
        shift
        parse_start_args "$@"
        ;;
      stop)
        CMD=stop
        shift
        parse_stop_args "$@"
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
print_data

# Eecute command
case $CMD in
  deploy)
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
