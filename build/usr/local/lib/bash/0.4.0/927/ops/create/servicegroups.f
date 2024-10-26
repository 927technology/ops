927.ops.create.servicegroups () {
  # description
  # creates ops hosts group stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path
  ## -t/--template if this will be a template or a configuraton.  sets the register option.

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f


  # argument variables
  local _json=
  local _path=
  local _temtemplate=${false}


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # hostgroup variables
	local _action_url=
	local _alias=
	local _members=
	local _notes=
	local _notes_url=
	local _servicegroup_members=
  local _servicegroup_name=


  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
      ;;
      -p | --path )
        shift
        _path=${1}
      ;;
      -t | --template )
        _template=${true}
      ;;
    esac
    shift
  done

  ## main
  if [[ ! -z ${_json} ]] && [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '. | length' ) > 0 ]]; then
    [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path} || ${cmd_rm} -rf ${_path}/*
    for hostgroup in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 

      _alias=$(                         ${cmd_echo} ${hostgroup}  | ${cmd_jq} -r  '.name.alias | if( . == null ) then "" else . end' )
      _members=$(                       ${cmd_echo} ${hostgroup}  | ${cmd_jq} -r  '[ .members[]     | select( .enable == true ).name ] | if( . | length < 1 ) then "" else join(", ") end' )
      _notes=$(                         ${cmd_echo} ${hostgroup}  | ${cmd_jq} -r  '.notes.string | if( . == null ) then "" else . end' )
      _notes_url=$(                     ${cmd_echo} ${hostgroup}  | ${cmd_jq} -r  '.notes_url | if( . == null ) then "" else . end' )
      _servicegroup_members=$(          ${cmd_echo} ${hostgroup}  | ${cmd_jq} -r  '[ .hostgroup_members[]     | select( .enable == true ).name ] | if( . | length < 1 ) then "" else join(", ") end' )
      _servicegroup_name=$(             ${cmd_echo} ${hostgroup}  | ${cmd_jq} -r  '.name.string | if( . == null ) then "" else . end' )



      ${cmd_echo} Writing Host Group: ${_path}/${_name}.cfg
      ${cmd_cat} << EOF.servicegroup > ${_path}/${_name}.cfg
define servicegroup                    {
  $( [[ ! -z ${_action_url} ]]            && ${cmd_printf} '%-1s %-32s %-50s' "" action_url "${_action_url}" )
  $( [[ ! -z ${_alias} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" alias "${_alias}" )
  $( [[ ! -z ${_members} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" members "${_members}" )
  $( [[ ! -z ${_notes} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" notes "${_notes}" )
  $( [[ ! -z ${_notes_url} ]]             && ${cmd_printf} '%-1s %-32s %-50s' "" notes_url "${_notes_url}" )
  $( [[ ${_template} ]]                   && ${cmd_printf} '%-1s %-32s %-50s' "" register "${false}" || ${cmd_printf} '%-1s %-32s %-50s' "" register "${true}" )
  $( [[ ! -z ${_servicegroup_members} ]]  && ${cmd_printf} '%-1s %-32s %-50s' "" servicegroup_members "${_servicegroup_members}" )
  $( [[ ! -z ${_servicegroup_name} ]]     && ${cmd_printf} '%-1s %-32s %-50s' "" servicegroup_name "${_servicegroup_name}" )
}
EOF.servicegroup

      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
      ${cmd_sed} -i '/^  $/d' ${_path}/${_alias}.cfg
    done 

    if [[ ${_error_count} > 0 ]]; then
      _exit_code=${exit_crit}
      _exit_strin=${false}

    else  
      _exit_code=${exit_ok}
      _exit_strin=${true}

    fi

    # exit
    ${cmd_echo} ${_exit_string}
    return ${_exit_code}
  fi
}