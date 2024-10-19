#!/bin/bash

## bools
true=1
false=0

## commands
cmd_echo=/bin/echo
cmd_jq=/bin/jq
cmd_oci=/var/mod_gearman/bin/oci

## exit
exit_ok=0
exit_crit=2
exit_unkn=3
exit_warn=1

## variables
_json="{}"
_resource=
_exit_code=${exit_unkn}
_exit_string=
_output="{}"
_query=

# main
## parse arguments
while [[ ${1} != "" ]]; do
  case ${1} in
    --resource | -r )
      shift
      _resource=${1}
    ;;
  esac
  shift
done

## query oci
case ${_resource} in
  compartment )
    _output=$( ${cmd_oci} iam compartment list | ${cmd_jq} -c )
    ${cmd_echo} ${_output} | ${cmd_jq} 2>&1 > /dev/null && _exit_code=${exit_ok}
  ;;
esac

## write json
_json=$( ${cmd_echo} ${_json} | ${cmd_jq} '.configuration.resource    |=.+ "'${_resource}'"' )
_json=$( ${cmd_echo} ${_json} | ${cmd_jq} '.configuration.exit_code   |=.+ '${_exit_code} )

_json=$( ${cmd_echo} ${_json} | ${cmd_jq} '.output                    |=.+ '"${_output}" )

## compress json
_json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c )

## exit
${cmd_echo} "${_json}"
exit ${_exit_code}