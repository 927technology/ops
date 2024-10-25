927.ops.create.hostgroups () {
  # description
  # creates ops hosts group stanzas based on json configuration provided
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
  local _hostgroup_name=
	 local _alias=
	 local _members=
	 local _hostgroup_members=
	 local _notes=
	 local _notes_url=
	 local _action_url=

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
  if [[ ! -z ${_json} ]]; then
    [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path} || ${cmd_rm} -rf ${_path}/*
    
    for hostgroup in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
      _alias=$( ${cmd_echo} ${hostgroup} | ${cmd_jq} -r '.alias' )
      _name=$( ${cmd_echo} ${hostgroup} | ${cmd_jq} -r '.name' )



      ${cmd_echo} Writing Host Group: ${_path}/${_name}.cfg
      ${cmd_cat} << EOF.hostgroup > ${_path}/${_name}.cfg
define hostgroup                    {
  hostgroup_name	                  ${_name}
  alias	                            ${_alias}
}
EOF.hostgroup

      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
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