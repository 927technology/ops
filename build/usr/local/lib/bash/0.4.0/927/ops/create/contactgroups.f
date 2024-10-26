927.ops.create.contactgroups () {
  # description
  # creates ops contact group stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path

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
  local _alias=
  local _contactgroup_members=
	local _contactgroup_name=
  local _members=


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
    for contactgroup in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
      _alias=$(                         ${cmd_echo} ${contactgroup}  | ${cmd_jq} -r  '.name.display | if( . == null ) then "" else . end' )
      _file_name=$(                     ${cmd_echo} ${contactgroup}  | ${cmd_jq} -r  '.name.string | if( . == null ) then "" else . end' )
      _contactgroup_members=$(          ${cmd_echo} ${contactgroup}  | ${cmd_jq} -r  '[ .members[] | select( .enable == true ).name ] | if( . | length < 1 ) then "" else join(", ") end' )
      _contactgroup_name=$(             ${cmd_echo} ${contactgroup}  | ${cmd_jq} -r  '.name.string | if( . == null ) then "" else . end' )
      _members=$(                       ${cmd_echo} ${contactgroup}  | ${cmd_jq} -r  '[ .members[] | select( .enable == true ).name ] | if( . | length < 1 ) then "" else join(", ") end' )

      ${cmd_echo} Writing Contact Group: ${_path}/${_file_name}.cfg
      ${cmd_cat} << EOF.contactgroup > ${_path}/${_file_name}.cfg
      
define contactgroup               {
$( [[ ! -z ${_alias} ]]               && ${cmd_printf} '%-1s %-32s %-50s\n' "" alias "${_alias}" )
$( [[ ! -z ${_contactroup_members} ]] && ${cmd_printf} '%-1s %-32s %-50s\n' "" contactgroup_members "${_contactgroup_members}" )
$( [[ ! -z ${_contactgroup_name} ]]   && ${cmd_printf} '%-1s %-32s %-50s\n' "" contactgroup_name "${_contactgroup_name}" )
$( [[ ! -z ${_members} ]]             && ${cmd_printf} '%-1s %-32s %-50s\n' "" members "${_members}" )
$( [[ ${_template} == ${true} ]]      && ${cmd_printf} '%-1s %-32s %-50s\n' "" register "${false}" || ${cmd_printf} '%-1s %-32s %-50s' "" register "${true}" )
}
EOF.contactgroup

      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
      ${cmd_sed} -i '/^$/d' ${_path}/${_file_name}.cfg
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