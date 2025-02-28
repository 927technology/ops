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
_ljson=${1}
_rjson=${2}


# control variables
_error_count=0
_exit_code=${exit_unkn}
_exit_string=


# variables


# main
## parse arguments

${cmd_echo} ${_ljson}

${cmd_echo}

${cmd_echo} ${_rjson}

