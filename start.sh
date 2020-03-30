#!/bin/bash

if [[  $__START__ != true ]];
then
  parse_start_args() {
    printf "Start n args: %s\n" "$#"
    printf "Start args: %s\n" "$@"
    printf "NOT IMPLEMENTED YET\n"
  }

  execute_start_command() {
    printf "Executing start command ...\n"

    printf "Done\n"
  }

  readonly __START__=true
fi
