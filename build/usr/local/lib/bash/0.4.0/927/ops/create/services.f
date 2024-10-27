927.ops.create.services () {
  # description
  # creates ops services stanzas based on json configuration provided
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
  local _template=${false}

  
  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # service variables
  local _action_url=
  local _check_command=
  local _check_freshness=
  local _contacts=
  local _contact_groups=
  local _freshness_threshold=
  local _check_interval=
  local _check_period=
  local _active_checks_enabled=
  local _high_flap_threshold=
  local _low_flap_threshold=
  local _max_check_attempts=
  local _passive_checks_enabled=
  local _retry_interval=
  local _event_handler_enabled=
  local _event_handler=
  local _flap_detection_enabled=
  local _flap_detection_options=
  local _host_names=
  local _display_name=
  local _hostgroup_name=
  local _icon_image=
  local _icon_image_alt=
  local _initial_state=
  local _is_volatile=
  local _notes=
  local _notes_url=
  local _notifications_enabled=
  local _first_notification_delay=
  local _notification_interval=
  local _notification_period=
  local _notification_options=
  local _obsess_over_service=
  local _process_perf_data=
  local _retain_status_information=
  local _retain_nonstatus_information=
  local _service_description=
  local _servicegroups=
  local _stalking_options=
  local _use=
  
  
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
    
    for service in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
      _action_url=$(                    ${cmd_echo} ${service}  | ${cmd_jq} -r  '.is_volatile | if( . == null ) then "" else . end' )
      _active_checks_enabled=$(         ${cmd_echo} ${service}  | ${cmd_jq} -r  '.check.active | if( . == null ) then "" else . end' )
      _check_command=$(                 ${cmd_echo} ${service}  | ${cmd_jq} -r  '.check.command | if( . == null ) then "" else . end' )
      _check_freshness=$(               ${cmd_echo} ${service}  | ${cmd_jq} -r  '.check.freshness.enable | if( . == null ) then "" else . end' )
      _freshness_threshold=$(           ${cmd_echo} ${service}  | ${cmd_jq} -r  '.check.freshness.threshold | if( . == null ) then "" else . end' )
      _initial_state=$(                 ${cmd_echo} ${service}  | ${cmd_jq} -r  '.initial_state | if( . == null ) then "" else . end' )
      _check_interval=$(                ${cmd_echo} ${service}  | ${cmd_jq} -r  '.check.interval.value | if( . == null ) then "" else . end' )
      _retry_interval=$(                ${cmd_echo} ${service}  | ${cmd_jq} -r  '.check.interval.retry | if( . == null ) then "" else . end' )
      _max_check_attempts=$(            ${cmd_echo} ${service}  | ${cmd_jq} -r  '.check.max_attempts | if( . == null ) then "" else . end' )
      _passive_checks_enabled=$(        ${cmd_echo} ${service}  | ${cmd_jq} -r  '.check.passive | if( . == null ) then "" else . end' )
      _process_perf_data=$(             ${cmd_echo} ${service}  | ${cmd_jq} -r  '.check.perfdata | if( . == null ) then "" else . end' )
      _check_period=$(                  ${cmd_echo} ${service}  | ${cmd_jq} -r  '.check.period | if( . == null ) then "" else . end' )
      _contacts=$(                      ${cmd_echo} ${service}  | ${cmd_jq} -r  '[ .contacts[] | select( .enable == true ) ] | if( . | length < 1 ) then "" else join(", ") end' )
      _contact_groups=$(                ${cmd_echo} ${service}  | ${cmd_jq} -r  '[ .contact_groups[] | select( .enable == true ) ] | if( . | length < 1 ) then "" else join(", ") end' )
      _event_handler_enabled=$(         ${cmd_echo} ${service}  | ${cmd_jq} -r  '.event_handler.enable | if( . == null ) then "" else ( if( . == true ) then '${true}' else '${false}' end ) end' )
      _event_handler=$(                 ${cmd_echo} ${service}  | ${cmd_jq} -r  '.event_handler.name | if( '${_event_handler_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _file_name=$(                     ${cmd_echo} ${service}  | ${cmd_jq} -r  '.name.string | if( . == null ) then "" else . end' )
      _flap_detection_enabled=$(        ${cmd_echo} ${service}  | ${cmd_jq} -r  '.flap_detection.enable | if( . == null ) then "" else ( if( . == true ) then '${true}' else '${false}' end ) end' )
      _flap_detection_options=$(        ${cmd_echo} ${service}  | ${cmd_jq} -r  '[ .flap_detection.options | to_entries[] | select(.value == true) | .key[0:1] ] | if( '${_flap_detection_enabled}' == '${false}' ) then "" else ( if( . | length < 1 ) then "" else join(", ") end ) end' )
      _high_flap_threshold=$(           ${cmd_echo} ${service}  | ${cmd_jq} -r  '.flap_detection.threshold.high | if( '${_flap_detection_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _low_flap_threshold=$(            ${cmd_echo} ${service}  | ${cmd_jq} -r  '.flap_detection.threshold.low | if( '${_flap_detection_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _host_name=$(                     ${cmd_echo} ${service}  | ${cmd_jq} -r  '.name.string | if( . == null ) then "" else . end' )
      _hostgroup_names=$(               ${cmd_echo} ${service}  | ${cmd_jq} -r  '[ .hostgroups[]     | select( .enable == true ).name ] | if( . | length < 1 ) then "" else join(", ") end' )
      _host_names=$(                    ${cmd_echo} ${service}  | ${cmd_jq} -r  '[ .hosts[]     | select( .enable == true ).name ] | if( . | length < 1 ) then "" else join(", ") end' )
      _icon_image=$(                    ${cmd_echo} ${service}  | ${cmd_jq} -r  '.icon.file.image | if( . == null ) then "" else . end' )
      _icon_image_alt=$(                ${cmd_echo} ${service}  | ${cmd_jq} -r  '.icon.file.alternate | if( . == null ) then "" else . end' )
      _is_volatile=$(                   ${cmd_echo} ${service}  | ${cmd_jq} -r  '.is_volatile | if( . == null ) then "" else . end' )
      _display_name=$(                  ${cmd_echo} ${service}  | ${cmd_jq} -r  '.name.alias | if( . == null ) then "" else . end' )
      _service_description=$(           ${cmd_echo} ${service}  | ${cmd_jq} -r  '.name.display | if( . == null ) then "" else . end' )
      _notes=$(                         ${cmd_echo} ${service}  | ${cmd_jq} -r  '.notes.string | if( . == null ) then "" else . end' )
      _notes_url=$(                     ${cmd_echo} ${service}  | ${cmd_jq} -r  '.notes.url | if( . == null ) then "" else . end' )
      _notifications_enabled=$(         ${cmd_echo} ${service}  | ${cmd_jq} -r  '.notification.enable | if( . == null ) then "" else ( if( . == true ) then '${true}' else '${false}' end ) end' )
      _first_notification_delay=$(      ${cmd_echo} ${service}  | ${cmd_jq} -r  '.notification.first_delay | if( '${_notifications_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _notification_interval=$(         ${cmd_echo} ${service}  | ${cmd_jq} -r  '.notification.interval | if( '${_notifications_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _notification_options=$(          ${cmd_echo} ${service}  | ${cmd_jq} -r  '[ .notification.options | to_entries[] | select(.value == true) | .key[0:1] ] | if( '${_notifications_enabled}' == '${false}' ) then "" else ( if( . | length < 1 ) then "" else join(", ") end ) end' )
      _notification_period=$(           ${cmd_echo} ${service}  | ${cmd_jq} -r  '.notification.period | if( '${_notifications_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _obsess_over_service=$(           ${cmd_echo} ${service}  | ${cmd_jq} -r  '.obsess | if( . == null ) then "" else . end' )
      _retain_nonstatus_information=$(  ${cmd_echo} ${service}  | ${cmd_jq} -r  '.retain.nonstatus | if( . == null ) then "" else . end' )
      _retain_status_information=$(     ${cmd_echo} ${service}  | ${cmd_jq} -r  '.retain.status | if( . == null ) then "" else . end' )
      _servicegroups=$(                 ${cmd_echo} ${service}  | ${cmd_jq} -r  '[ .servicegroups[]     | select( .enable == true ).name ] | if( . | length < 1 ) then "" else join(", ") end' )
      _stalking_options=$(              ${cmd_echo} ${service}  | ${cmd_jq} -r  '[ .notification.options | to_entries[] | select(.value == true) | .key[0:1] ] | if( . | length < 1 ) then "" else join(", ") end' )
      _use=$(                           ${cmd_echo} ${service}  | ${cmd_jq} -r  '.use | if( . == null ) then "" else . end' )


      ${cmd_echo} Writing Service: ${_path}/${_file_name}.cfg
      ${cmd_cat} << EOF.service > ${_path}/${_file_name}.cfg
define service                         {
$( [[ ! -z ${_active_checks_enabled} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" active_checks_enabled "${_active_checks_enabled}" )
$( [[ ! -z ${_action_url} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" action_url "${_action_url}" )
$( [[ ! -z ${_check_command} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" check_command "${_check_command}" )
$( [[ ! -z ${_check_freshness} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" check_freshness "${_check_freshness}" )
$( [[ ! -z ${_freshness_threshold} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" freshness_threshold "${_freshness_threshold}" )
$( [[ ! -z ${_initial_state} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" initial_state "${_initial_state}" )
$( [[ ! -z ${_check_interval} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" check_interval "${_check_interval}" )
$( [[ ! -z ${_retry_interval} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" retry_interval "${_retry_interval}" )
$( [[ ! -z ${_max_check_attempts} ]]            && ${cmd_printf} '%-1s %-32s %-50s' "" max_check_attempts "${_max_check_attempts}" )
$( [[ ! -z ${_passive_checks_enabled} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" passive_checks_enabled "${_passive_checks_enabled}" )
$( [[ ! -z ${_process_perf_data} ]]             && ${cmd_printf} '%-1s %-32s %-50s' "" process_perf_data "${_process_perf_data}" )
$( [[ ! -z ${_check_period} ]]                  && ${cmd_printf} '%-1s %-32s %-50s' "" check_period "${_check_period}" )
$( [[ ! -z ${_contacts} ]]                      && ${cmd_printf} '%-1s %-32s %-50s' "" contacts "${_contacts}" )
$( [[ ! -z ${_contact_groups} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" contact_groups "${_contact_groups}" )
$( [[ ! -z ${_event_handler} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" event_handler "${_event_handler}" )
$( [[ ! -z ${_event_handler_enabled} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" event_handler_enabled "${_event_handler_enabled}" )
$( [[ ! -z ${_flap_detection_enabled} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" flap_detection_enabled} "${_flap_detection_enabled}" )
$( [[ ! -z ${_flap_detection_options} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" flap_detection_options "[${_flap_detection_options}]" )
$( [[ ! -z ${_high_flap_threshold} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" high_flap_threshold "${_high_flap_threshold}" )
$( [[ ! -z ${_low_flap_threshold} ]]            && ${cmd_printf} '%-1s %-32s %-50s' "" low_flap_threshold "${low_flap_threshold}" )
$( [[ ! -z ${_host_names} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" host_name "${_host_names}" )
$( [[ ! -z ${_hostgroup_names} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" hostgroup_name "${_hostgroup_names}" )
$( [[ ! -z ${_icon_image} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" icon_image"${_icon_image}" )
$( [[ ! -z ${_icon_image_alt} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" icon_image_alt"${_icon_image_alt}" )
$( [[ ! -z ${_is_volatile} ]]                   && ${cmd_printf} '%-1s %-32s %-50s' "" is_volatile "${_is_volatile}" )
$( [[ ! -z ${_display_name} ]]                  && ${cmd_printf} '%-1s %-32s %-50s' "" display_name "${_display_name}" )
$( [[ ! -z ${_service_description} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" service_description "${_service_description}" )
$( [[ ! -z ${_notes} ]]                         && ${cmd_printf} '%-1s %-32s %-50s' "" notes "${_notes}" )
$( [[ ! -z ${_notes_url} ]]                     && ${cmd_printf} '%-1s %-32s %-50s' "" notes_url "${_notes_url}" )
$( [[ ! -z ${_first_notification_delay} ]]      && ${cmd_printf} '%-1s %-32s %-50s' "" first_notification_delay "${_first_notification_delay}" )
$( [[ ! -z ${_notification_interval} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" notification_interval "${_notification_interval}" )
$( [[ ! -z ${_notification_options} ]]          && ${cmd_printf} '%-1s %-32s %-50s' "" notification_options "[${_notification_options}]" )
$( [[ ! -z ${_notification_period} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" notification_period "${_notification_period}" )
$( [[ ! -z ${_notifications_enabled} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" notifications_enabled "${_notifications_enabled}" )
$( [[ ! -z ${_obsess_over_host} ]]              && ${cmd_printf} '%-1s %-32s %-50s' "" obsess_over_host "${_obsess_over_host}" )
$( [[ ! -z ${_retain_nonstatus_information} ]]  && ${cmd_printf} '%-1s %-32s %-50s' "" retain_nonstatus_information "${_retain_nonstatus_information}" )
$( [[ ! -z ${_retain_status_information} ]]     && ${cmd_printf} '%-1s %-32s %-50s' "" retain_status_information "${_retain_status_information}" )
$( [[ ! -z ${_stalking_options} ]]              && ${cmd_printf} '%-1s %-32s %-50s' "" stalking_options "[${_stalking_options}]" )
$( [[ ! -z ${_servicegroups} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" servicegroups "${_servicegroups}" )
}
EOF.service

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