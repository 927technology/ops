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
_exit_json="{}"
_exit_resource=

# parse command arguments
while [[ ${1} != "" ]]; do
  case ${1} in
    -h | --host )
      shift
      _host="${1}"
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

# main
case ${_resource} in
  compartment | compartments )
    if [[ ! -z ${_host} ]]    &&              \
       [[ ! -z ${_service} ]]; then
      _exit_resource=compartments
      _json=$( ${cmd_printf} "GET services\nColumns: plugin_output\nFilter: display_name ~ ${_service}\nFilter: host_name ~ ${_host}\n" | ${cmd_unixcat} /var/cache/naemon/live | ${cmd_jq} -sc )
    echo test ---------------
    echo $_json
    echo test ---------------
    fi
  ;;
  drg | drgs )
    if [[ ! -z ${_host} ]]    &&              \
       [[ ! -z ${_service} ]]; then
      _exit_resource=drgs
      _json=$( ${cmd_printf} "GET services\nColumns: plugin_output\nFilter: display_name ~ ${_service}\nFilter: host_name ~ ${_host}\n" | ${cmd_unixcat} /var/cache/naemon/live | ${cmd_jq} -sc '.drgs' )
    fi
  ;;
esac


_exit_string=$( ${cmd_echo} ${_exit_json} | ${cmd_jq} '.'${_exit_resource}' |=.+ '"${_json}" )

${cmd_echo} ${_exit_string} | ${cmd_jq} -c
