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


# argument variables
_host=
_resource=
_service=


# control variables
_error_count=0
_exit_code=${exit_unkn}
_exit_string=


# variables
_json=

# parse command arguments
while [[ ${1} != "" ]]; do
  case ${1} in
    -h | --host )
      shift
      _host=${1}
    ;;
    -r | --resource )
      shift
      _resource=${1}
    ;;
    -s | --service )
      shift
      _service=${1}
    ;;
  esac
  shift
done

_json=$( 927.livestatus.get -h ${_host} -r ${_resource}  -s ${_service} 2>/dev/null ) 
[[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
[[ -z ${_json} ]] && _json="{}"

# _time_diff=$(( $( date.epoch ) - $( ${cmd_echo} ${_json} | ${cmd_jq} '.date.epoch' ) ))
# [[ ${_time_diff}  > 180 ]]  && _exit_code=${exit_warn}
# [[ ${_time_diff}  > 320 ]]  && _exit_code=${exit_crit}

${cmd_echo} ${_json}
exit ${_exit_code}