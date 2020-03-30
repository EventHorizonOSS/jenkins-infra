#!/bin/bash

if [[  $__RETART__ != true ]];
then
  restart_usage() {
    printf "\n"

    printf "NAME\n"
    printf "%7s %s\n" "sdfdsfd" "$0"

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

  parse_restart_args() {
    printf "Restart n args: %s\n" "$#"
    printf "Restart args: %s\n" "$@"
    printf "NOT IMPLEMENTED YET\n"
  }

  execute_restart_command() {
    printf "Executing restart command ...\n"

    restart_usage

    printf "Done\n"
  }

  readonly __RESTART__=true
fi
