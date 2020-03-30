#!/bin/bash

if [[  $__DEPLOY__ != true ]];
then
  parse_deploy_args() {
    printf "Deploy n args: %s\n" "$#"
    printf "Deploy args: %s\n" "$@"
  }

  execute_deploy_command() {
    printf "Executing deploy command ...\n"

    printf "NOT IMPLEMENTED YET\n"

    printf "Done\n"
  }

  readonly __DEPLOY__=true
fi
