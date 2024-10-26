927.ops.create.timeperiods () {
  # description
  # creates ops templates stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path the full path to the associated conf.d write path
  ## -t/--template if this will be a template or a configuraton.  sets the register option.

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # argument variables
  local _json=
  local _path=
  local _template=${false}


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # timeperiod variables
	local _timeperiod_name=
  local _alias=
  local _excludes=
  local _ranges=
  local _template_day=
  local _template_end=
  local _template_start=


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

    for timeperiod in $(                ${cmd_echo} ${_json}      | ${cmd_jq} -c  '.[] | select( .enable == true )' ); do 
      _alias=$(                         ${cmd_echo} ${timeperiod} | ${cmd_jq} -r  '.name.alias | if( . == null ) then "" else . end' )
      #_excludes=
      _ranges=$(                        ${cmd_echo} ${timeperiod} | ${cmd_jq} -r  '.ranges | select( .enable == true )' )
      _timeperiod_name=$(               ${cmd_echo} ${timeperiod} | ${cmd_jq} -r  '.name.string | if( . == null ) then "" else . end' )


      # write file
      ${cmd_echo} Writing Timeperiods: ${_path}/${_name}.cfg
      ${cmd_cat} << EOF.timeperiod > ${_path}/${_name}.cfg
define timeperiod                       {
  $( [[ ! -z ${_alias} ]]                         && ${cmd_printf} '%-1s %-32s %-50s' "" "alias" "${_alias}" )
  $( [[ ${_template} ]]                           && ${cmd_printf} '%-1s %-32s %-50s' "" register "${false}" || ${cmd_printf} '%-1s %-32s %-50s' "" register "${true}" )
  $(  if [[ $( ${cmd_echo} ${_ranges} | ${cmd_jq} '.[] | select( .enable == true ) | length )' ) > 0 ]]; then
        for template in $(    ${cmd_echo} ${_ranges}  | ${cmd_jq} '.[] | select( .enable == true' ); do
          _template_day=$(    ${cmd_echo} ${template} | ${cmd_jq} '.day' )
          _template_end=$(    ${cmd_echo} ${template} | ${cmd_jq} '.time.end' )
          _template_start=$(  ${cmd_echo} ${template} | ${cmd_jq} '.time.start' )

          ${cmd_printf} '%-1s %-32s %-50s' "" "${template_day}" "${_template_start}"-"${_template_end}" )
        done
      fi
  )

  $( [[ ! -z ${_timeperiod_name} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" timeperiod_name "${_timeperiod_name}" )
}
EOF.timeperiod

      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
      ${cmd_sed} -i '/^  $/d' ${_path}/${_name}.cfg
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