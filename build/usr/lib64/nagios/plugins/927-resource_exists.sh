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
_tenant=


# control variables
_err_count=0
_exit_code=${exit_unkn}
_exit_string=


# variables
_count=0
_iac=
_iac_label=
_infra=
_infra_label=
_infra_tenant=
_json="{}"

# main
## parse arguments
while [[ ${1} != "" ]]; do
  case ${1} in
    -r | --resource )
      shift
      case ${1} in
        compartment | compartments )
          _resource=compartments
        ;;
      esac
    ;;
    -T | --tenancy )
      shift
      _tenancy=${1}
    ;;
    -t | --tenant )
      shift
      _tenant=${1}
    ;;
  esac
  shift
done


_iac=$( /usr/lib64/naemon/plugins/927-livestatus_get.sh -h ${_tenant} -r ${_resource} -s iac-config | sed 's/ /_/g' )
_infra=$( /usr/lib64/naemon/plugins/927-livestatus_get.sh -h ${_tenancy} -r ${_resource} -s infra-${_resource}  )



echo $_iac | jq '.data[].'${_resource}'[]' | jq -c
echo 
echo $_infra 
# echo
# echo ${_infra} | jq '.data[].'${_resource}'[]' | jq -c


# validate label exists in in iac and in infra for iac
# while IFS= read iac_item; do
#   _iac_item=$( ${cmd_echo} "${iac_item}" | ${cmd_jq} -r '.label' )

#   echo iac item
#   echo $_iac_item
#   while IFS= read infra_item; do
#     _coumt=0


#     _infra_label=$( ${cmd_echo} "${infra_item}" | ${cmd_jq} -r '."defined-tags"."927-ops".label' )
#     _infra_tenant=$( ${cmd_echo} "${infra_item}" | ${cmd_jq} -r '."defined-tags"."927-ops".tenant' )

    
#     echo infra item
#     echo $_infra_label
#     echo $_infra_tenant

#     # if [[ ${_infra_label} == ${_iac_label} ]]     && \
#     #    [[ ${_infra_tenant} == ${_tenant} ]]       && \
#     #    [[ ${_infra_label}   != null ]]            && \
#     #    [[ ${_infra_tenant}  != null ]]; then

#     #   echo $_infra_label
#     #   echo $_iac_label
#     #   echo
#     #   (( _count++ ))


#     # fi

#     # if [[ ${_count} > 1 ]]; then
#     #   echo iac
#     #   echo iac label:     ${_iac_label}
#     #   echo tenancy:       ${_tenancy}
#     #   echo tenant:        ${_tenant}
#     #   echo

#     #   _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.data.iac['${_count}'].iac.label     |=.+ "'"${_iac_label}"'"' )
#     #   _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.data.iac['${_count}'].tenancy       |=.+ "'"${_tenancy}"'"' )
#     #   _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.data.iac['${_count}'].tenant        |=.+ "'"${_tenant}"'"' )

#     #   (( _err_count++ ))
#     # fi

#   done < <( ${cmd_echo} "${_infra}" | ${cmd_jq} -c '.data[].'${_resource}'[]' )

# echo

# done < <( ${cmd_echo} "${_iac}" | ${cmd_jq} -c '.data[].'${_resource}'[]' )

# reset count for infra check
_count=0

# validate label exists in in iac and in infra for infra
# while IFS= read infra_item; do
#   _infra_tenant=$( ${cmd_echo} "${infra_item}" | ${cmd_jq} -r '."defined-tags"."927-ops".tenant' )
#   _infra_label=$( ${cmd_echo} "${infra_item}" | ${cmd_jq} -r '."defined-tags"."927-ops".label' )

#   while IFS= read iac_item; do
#     _iac_label=$( ${cmd_echo} "${iac_item}" | ${cmd_jq} -r '.label' )
  
#     # echo infra
#     # echo iac label:     ${_iac_label}
#     # echo tenancy:       ${_tenancy}
#     # echo tenant:        ${_tenant}
#     # echo infra label:   ${_infra_label}
#     # echo infra tenant:  ${_infra_tenant}
#     # echo

#     if [[ ${_infra_label} != ${_iac_label} ]]       && \
#        [[ ${_infra_tenant} == ${_tenant} ]]         && \
#        [[ ! -z ${_iac_label} ]]                     && \
#        [[ ! -z ${_tenancy} ]]; then
#       _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.data.infra['${_count}'].infra.label   |=.+ "'"${_infra_label}"'"' )
#       _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.data.infra['${_count}'].tenancy       |=.+ "'"${_tenancy}"'"' )
#       _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.data.infra['${_count}'].tenant        |=.+ "'"${_tenant}"'"' )

#       (( _count++ ))
#       (( _err_count++ ))
#     fi
    
#   done < <( ${cmd_echo} "${_iac}" | ${cmd_jq} -c '.data[].'${_resource}'[]' )

# done < <( ${cmd_echo} "${_infra}" | ${cmd_jq} -c '.data[].'${_resource}'[]' )

# exit status
# [[ ${_err_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
# _exit_string="${_json}"

# #return
# ${cmd_echo} "${_exit_string}"
# exit ${_exit_code}