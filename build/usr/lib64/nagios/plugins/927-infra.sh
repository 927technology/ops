#!/bin/bash

# library root
export _lib_root=/usr/local/lib/bash/${LIB_VERSION}

# source libraries
. ${_lib_root}/927/variables/cmd_el.v
. ${_lib_root}/927/variables.l
. ${_lib_root}/date/epoch.f
. ${_lib_root}/date/pretty.f
. ${_lib_root}/json.l
. ${_lib_root}/927/livestatus.l
. ${_lib_root}/927/ops.l
. ${_lib_root}/927/oci/get.f


# argument variables
_profile=
_resource=


# control variables
_error_count=0
_exit_code=${exit_unkn}
_exit_string=


# variables
_json="{}"
_json_timestamp=$( json.timestamp )

# main
## parse arguments
while [[ ${1} != "" ]]; do
  case ${1} in
    -p | --profile )
      shift
      _profile=${1}
    ;;
    -r | --resource )
      shift
      _resource=${1}
    ;;
  esac
  shift
done

## query oci
case ${_resource} in
  compartment | compartments )
    _output=$( 927.oci.get -r ${_resource} -p ${_profile} | ${cmd_jq} -c )
    _exit_code=${?}
  ;;
esac


## write json
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.          |=.+ '"${_output}" )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.          |=.+ '"${_json_timestamp}" )





_exit_string=${_json}

# exit
${cmd_echo} ${_exit_string}
exit ${_exit_code}