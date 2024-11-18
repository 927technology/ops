#!/bin/bash

# because IFS sucks
IFS=$'\n'

# source config
. /usr/local/etc/ops/management.cfg


# library root
export _lib_root=/usr/local/lib/bash/${LIB_VERSION}

# source libraries
. ${_lib_root}/927/variables.l
. ${_lib_root}/927/ops.l
. ${_lib_root}/json.l

## argument variables
_execution_target=
_region=
_tennant=
_tenancy=


# control variables
_error_count=0
_exit_code=${exit_unkn}
_exit_string=


# variables
_compartments_json=
_configuration_json="{}"
_exit_json="{}"
_exit_resource=


# parse command arguments
while [[ ${1} != "" ]]; do
  case ${1} in
    -et | --execution_target )
      shift
      _execution_target=${1}
    ;;
    -r | --region )
      shift
      _region=${1}
    ;;
    -t | --tennant )
      shift
      _tennant=${1}
    ;;
    -T | --tenancy )
      shift
      _tenancy=${1}
    ;;
  esac
  shift
done

# main
if [[ ! -z ${_execution_target} ]]  &&             \
   [[ ! -z ${_region} ]]            &&             \
   [[ ! -z ${_tennant} ]]           &&             \
   [[ ! -z ${_tenancy} ]]; then

  _compartments_json=$( usr/local/bin/output.sh -h compartment -s config-iac -r compartment | ${cmd_jq} '.compartments[] | select((( .placement.tenancy == "'${_tenancy}'" ) and .placement.tennant == "'${_tennant}'") and .placement.region == "'${_region}'")' | ${cmd_jq} -sc )

  _configuration_json=$( ${cmd_echo} ${_configuration_json} | ${cmd_jq} -c '.variables.config.type |=.+ "map"' )
  _configuration_json=$( ${cmd_echo} ${_configuration_json} | ${cmd_jq} -c '.variables.config.default.et.'${_execution_target}'.application |=.+ {}' )

  _configuration_json=$( ${cmd_echo} ${_configuration_json} | ${cmd_jq} -c '.variables.config.default.et.'${_execution_target}'.infrastructure.compartments |=.+ '"${_compartments_json}" )

  [[ ! -d /etc/927/conf.d/${_tenancy}/${_tennant}/${_region} ]] && ${cmd_mkdir} -p /etc/927/conf.d/${_tenancy}/${_tennant}/${_region}
  if [[ $( json.validate -j ${_configuration_json} ) == ${true} ]]; then
    ${cmd_echo} ${_configuration_json} | ${cmd_jq} > /etc/927/conf.d/${_tenancy}/${_tennant}/${_region}/v.config.json
  fi
fi