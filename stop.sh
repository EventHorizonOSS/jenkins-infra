#!/bin/bash

if [[  $__STOP__ != true ]];
then
  parse_stop_args() {
    printf "Stop n args: %s\n" "$#"
    printf "Stop args: %s\n" "$@"
    printf "NOT IMPLEMENTED YET\n"
  }

  execute_stop_command() {
    printf "Executing stop command ...\n"

    printf "Done\n"
  }

  readonly __STOP__=true
fi
