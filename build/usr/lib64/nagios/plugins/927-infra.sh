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
. ${_lib_root}/927/provider/get.f


# argument variables
_profile=
_provider=
_resource=


# control variables
_error_count=0
_exit_code=${exit_unkn}
_exit_string=


# variables
_json="{}"
_json_timestamp=$( json.timestamp )
_output="{}"

# main
## parse arguments
while [[ ${1} != "" ]]; do
  case ${1} in
    -p | --profile )
      shift
      _profile=${1}
    ;;
    -P | --provider )
      shift
      case ${1} in 
        oci | OCI )
          _provider=oci
        ;;
      esac
    ;;
    -r | --resource )
      shift
      case ${1} in
        compartment | compartments )
          _resource=compartments
        ;;
      esac
    ;;
  esac
  shift
done

## query provider
_output=$( 927.provider.get --provider ${_provider} --profile ${_profile} --resource ${_resource}  )
_exit_code=${?}

## write json
_json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.          |=.+ '"${_output}" )
_json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.          |=.+ '"${_json_timestamp}" )

_exit_string=${_json}

# exit
${cmd_echo} ${_exit_string}
exit ${_exit_code}