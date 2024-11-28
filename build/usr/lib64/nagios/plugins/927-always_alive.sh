#!/bin/bash

## bools
true=1
false=0

## commands
cmd_echo=/bin/echo

## exit
exit_ok=0
exit_crit=2
exit_unkn=3
exit_warn=1

${cmd_echo} Always Alive
exit ${exit_ok}