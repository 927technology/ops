927.ops.create.contacts () {
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


  # contact variables
  local _addresses=
  local _alias=
  local _can_submit_commands=
  local _contact_groups=
  local _email=
  local _host_notification_commands=
  local _host_notification_options=
  local _host_notification_period=
  local _host_notifications_enabled=
  local _name=
  local _pager=
  local _retain_status_information=
  local _retain_nonstatus_information=
  local _service_notification_commands=
  local _service_notification_options=
  local _service_notification_period=
  local _service_notifications_enabled=


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

    for contact in $(                   ${cmd_echo} ${_json}    | ${cmd_jq} -c  '.[] | select( .enable == true )' ); do 
      _alias=$(                         ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.name.alias | if( . == null ) then "" else . end' )
      _can_submit_commands=$(           ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.can_submit_commands | if( . == null ) then "" else . end' )
      _contact_groups=$(                ${cmd_echo} ${contact}  | ${cmd_jq} -r  '[ .contact_groups[] | select( .enable == true ) ] | if( . | length < 1 ) then "" else join(", ") end' )
      _email=$(                         ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.email | if( . == null ) then "" else . end' )
      _host_notifications_enabled=$(    ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.notification.host.enable | if( . == null ) then "" else ( if( . == true ) then '${true}' else '${false}' end ) end' )
      _host_notification_commands=$(    ${cmd_echo} ${contact}  | ${cmd_jq} -r  '[ .notification.host.commands[] | select(.enable == true).name ] | if( '${_host_notifications_enabled}' == '${false}' ) then "" else ( if( . | length < 1 ) then "" else join(", ") end ) end' )
      _host_notification_options=$(     ${cmd_echo} ${contact}  | ${cmd_jq} -r  '[ .notification.host.options | to_entries[] | select(.value == true) | .key[0:1] ] | if( '${_host_notifications_enabled}' == '${false}' ) then "" else ( if( . | length < 1 ) then "" else join(", ") end ) end' )
      _host_notification_period=$(      ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.notification.host.period | if( '${_host_notifications_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _name=$(                          ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.name.string | if( . == null ) then "" else . end' )
      _pager=$(                         ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.pager | if( . == null ) then "" else . end' )
      _retain_status_information=$(     ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.retain.status | if( . == null ) then "" else . end' )
      _retain_nonstatus_information=$(  ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.retain.nonstatus | if( . == null ) then "" else . end' )
      _service_notifications_enabled=$( ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.notification.service.enable | if( . == null ) then "" else ( if( . == true ) then '${true}' else '${false}' end ) end' )
      _service_notification_commands=$( ${cmd_echo} ${contact}  | ${cmd_jq} -r  '[ .notification.service.commands[] | select(.enable == true).name ] | if( '${_service_notifications_enabled}' == '${false}' ) then "" else ( if( . | length < 1 ) then "" else join(", ") end ) end' )
      _service_notification_options=$(  ${cmd_echo} ${contact}  | ${cmd_jq} -r  '[ .notification.service.options | to_entries[] | select(.value == true) | .key[0:1] ] | if( '${_service_notifications_enabled}' == '${false}' ) then "" else ( if( . | length < 1 ) then "" else join(", ") end ) end' )
      _service_notification_period=$(   ${cmd_echo} ${contact}  | ${cmd_jq} -r  '.notification.service.period | if( '${_service_notifications_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      

      # write file
      ${cmd_echo} Writing Template/Contact: ${_path}/${_name}.cfg
      ${cmd_cat} << EOF.contact > ${_path}/${_name}.cfg
define contact                       {
  $( [[ ! -z ${_alias} ]]                         && ${cmd_printf} '%-1s %-32s %-50s' "" "alias" "${_alias}" )
  $( [[ ! -z ${_can_submit_commands} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" can_submit_commands "${_can_submit_commands}" )
  $( [[ ! -z ${_contact_groups} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" contactgroups "${_contact_groups}" )
  $( [[ ! -z ${_email} ]]                         && ${cmd_printf} '%-1s %-32s %-50s' "" email "${_email}" )
  $( [[ ! -z ${_host_notification_commands} ]]    && ${cmd_printf} '%-1s %-32s %-50s' "" host_notification_commands "${_host_notification_commands}" )
  $( [[ ! -z ${_host_notification_options} ]]     && ${cmd_printf} '%-1s %-32s %-50s' "" host_notification_options "[${_host_notification_options}]" )
  $( [[ ! -z ${_host_notification_period} ]]      && ${cmd_printf} '%-1s %-32s %-50s' "" host_notificaiton_period "${_host_notification_period}" )
  $( [[ ! -z ${_host_notification_enabled} ]]     && ${cmd_printf} '%-1s %-32s %-50s' "" host_notifications_enabled "${_host_notification_enabled}" )
  $( [[ ! -z ${_name} ]]                          && ${cmd_printf} '%-1s %-32s %-50s' "" name "${_name}" )
  $( [[ ! -z ${_pager} ]]                         && ${cmd_printf} '%-1s %-32s %-50s' "" pager "${_pager}" )
  $( [[ ${_template} ]]                           && ${cmd_printf} '%-1s %-32s %-50s' "" register "${false}" || ${cmd_printf} '%-1s %-32s %-50s' "" register "${true}" )
  $( [[ ! -z ${_retain_status_information} ]]     && ${cmd_printf} '%-1s %-32s %-50s' "" retain_status_information "${_retain_status_information}" )
  $( [[ ! -z ${_retain_nonstatus_information} ]]  && ${cmd_printf} '%-1s %-32s %-50s' "" retain_nonstatus_informaiton "${_retain_nonstatus_information}" )
  $( [[ ! -z ${_service_notification_commands} ]] && ${cmd_printf} '%-1s %-32s %-50s' "" service_notification_commands "${_service_notification_commands}" )
  $( [[ ! -z ${_service_notification_options} ]]  && ${cmd_printf} '%-1s %-32s %-50s' "" service_notificaiton_options "[${_service_notification_options}]" )
  $( [[ ! -z ${_service_notification_period} ]]   && ${cmd_printf} '%-1s %-32s %-50s' "" service_notification_period "${_service_notification_period}" )
  $( [[ ! -z ${_service_notification_enabled} ]]  && ${cmd_printf} '%-1s %-32s %-50s' "" service_notification_enabled "${_service_notification_enabled}" )
}
EOF.contact

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