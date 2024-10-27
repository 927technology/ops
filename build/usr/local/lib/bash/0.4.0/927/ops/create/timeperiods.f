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
  local _range_day=
  local _range_end=
  local _range_start=
  local _ranges=


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
      _alias=$(                         ${cmd_echo} ${timeperiod} | ${cmd_jq} -r  '.name.display | if( . == null ) then "" else . end' )
      #_excludes=
      _file_name=$(                     ${cmd_echo} ${timeperiod} | ${cmd_jq} -r  '.name.string | if( . == null ) then "" else . end' )
      _ranges=$(                        ${cmd_echo} ${timeperiod} | ${cmd_jq} -r  '[ .ranges[] | select( .enable == true ) ]' )
      _timeperiod_name=$(               ${cmd_echo} ${timeperiod} | ${cmd_jq} -r  '.name.string | if( . == null ) then "" else . end' )


      # write file
      ${cmd_echo} Writing Timeperiods: ${_path}/${_file_name}.cfg
      ${cmd_cat} << EOF.timeperiod > ${_path}/${_file_name}.cfg
define timeperiod                       {
$( [[ ! -z ${_alias} ]]                         && ${cmd_printf} '%-1s %-32s %-50s\n' "" "alias" "${_alias}" )
$( [[ ${_template} == ${true} ]]                && ${cmd_printf} '%-1s %-32s %-50s\n' "" register "${false}" || ${cmd_printf} '%-1s %-32s %-50s\n' "" register "${true}" )
$( [[ ! -z ${_timeperiod_name} ]]               && ${cmd_printf} '%-1s %-32s %-50s\n' "" timeperiod_name "${_timeperiod_name}" )
  #-----------------  RANGES  -----------------#
$(  if [[ $( ${cmd_echo} ${_ranges} | ${cmd_jq} '.[] | length' ) > 0 ]]; then
      for range in $(    ${cmd_echo} ${_ranges}  | ${cmd_jq} -c '.[]' ); do
        _range_day=$(    ${cmd_echo} ${range} | ${cmd_jq} -r '.day' )
        _range_end=$(    ${cmd_echo} ${range} | ${cmd_jq} -r '.time.end' )
        _range_start=$(  ${cmd_echo} ${range} | ${cmd_jq} -r '.time.start' )

        ${cmd_printf} '%-1s %-32s %-50s\n' "" "${_range_day}" "${_range_start}"-"${_range_end}"
      done
    fi
)
}
EOF.timeperiod

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