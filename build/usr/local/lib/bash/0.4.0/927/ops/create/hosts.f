927.ops.create.hosts () {
  # description
  # creates ops hosts stanzas based on json configuration provided
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


  # host variables
  local _2d_coords=
  local _3d_coords=
  local _active_checks_enabled=
  local _action_url=
  local _address=
  local _alias=
  local _check_command=
  local _check_freshness=
  local _check_period=
  local _check_interval=
  local _contact_groups=
  local _contacts=
  local _display_name=
  local _event_handler=
  local _event_handler_enabled=
  local _first_notification_delay=
  local _flap_detection_enabled=
  local _flap_detection_options=
  local _freshness_threshold=
  local _high_flap_threshold=
  local _host_name=
  local _hostgroups=
  local _icon_image=
  local _icon_image_alt=
  local _initial_state=
  local _low_flap_threshold=
  local _max_check_attempts=
  local _notes=
  local _notes_url=
  local _notification_interval=
  local _notification_options=
  local _notification_period=
  local _notifications_enabled=
  local _obsess_over_host=
  local _parents=
  local _passive_checks_enabled=
  local _process_perf_data=
  local _retain_nonstatus_information=
  local _retain_status_information=
  local _retry_interval=
  local _stalking_options=
  local _statusmap_image=
  local _vrml_image=

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
    
    for host in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 
      _2d_coords=$(                     ${cmd_echo} ${host}  | ${cmd_jq} -r  '.icon.coordinates."2d" | if( .x >= 0 and .y >= 0 ) then [ .x, .y ] | join(", ") else "" end' )
      _3d_coords=$(                     ${cmd_echo} ${host}  | ${cmd_jq} -r  '.icon.coordinates."3d" | if( .x >= 0 and .y >= 0 and .z >= 0 ) then [ .x, .y, .z ] | join(", ") else "" end' )
      _active_checks_enabled=$(         ${cmd_echo} ${host}  | ${cmd_jq} -r  '.check.active | if( . == null ) then "" else . end' )
      _action_url=$(                    ${cmd_echo} ${host}  | ${cmd_jq} -r  '.action_url | if( . == null ) then "" else . end' )
      _address=$(                       ${cmd_echo} ${host}  | ${cmd_jq} -r  '.address | if( . == null ) then "" else . end' )
      _alias=$(                         ${cmd_echo} ${host}  | ${cmd_jq} -r  '.name.alias | if( . == null ) then "" else . end' )
      _check_command=$(                 ${cmd_echo} ${host}  | ${cmd_jq} -r  '.check.command | if( . == null ) then "" else . end' )
      _check_freshness=$(               ${cmd_echo} ${host}  | ${cmd_jq} -r  '.check.freshness.enable | if( . == null ) then "" else . end' )
      _check_period=$(                  ${cmd_echo} ${host}  | ${cmd_jq} -r  '.check.period | if( . == null ) then "" else . end' )
      _check_interval=$(                ${cmd_echo} ${host}  | ${cmd_jq} -r  '.check.interval.value | if( . == null ) then "" else . end' )
      _contact_groups=$(                ${cmd_echo} ${host}  | ${cmd_jq} -r  '[ .contact_groups[] | select( .enable == true ) ] | if( . | length < 1 ) then "" else join(", ") end' )
      _contacts=$(                      ${cmd_echo} ${host}  | ${cmd_jq} -r  '[ .contacts[] | select( .enable == true ) ] | if( . | length < 1 ) then "" else join(", ") end' )
      _display_name=$(                  ${cmd_echo} ${host}  | ${cmd_jq} -r  '.name.display | if( . == null ) then "" else . end' )
      _event_handler_enabled=$(         ${cmd_echo} ${host}  | ${cmd_jq} -r  '.event_handler.enable | if( . == null ) then "" else ( if( . == true ) then '${true}' else '${false}' end ) end' )
      # _event_handler=$(                 ${cmd_echo} ${host}  | ${cmd_jq} -r  '.event_handler.name | if( '${_event_handler_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      # _flap_detection_enabled=$(        ${cmd_echo} ${host}  | ${cmd_jq} -r  '.flap_detection.enable | if( . == null ) then "" else ( if( . == true ) then '${true}' else '${false}' end ) end' )
      # _flap_detection_options=$(        ${cmd_echo} ${host}  | ${cmd_jq} -r  '[ .flap_detection.options | to_entries[] | select(.value == true) | .key[0:1] ] | if( '${_flap_detection_enabled}' == '${false}' ) then "" else ( if( . | length < 1 ) then "" else join(", ") end ) end' )
      # _high_flap_threshold=$(           ${cmd_echo} ${host}  | ${cmd_jq} -r  '.flap_detection.threshold.high | if( '${_flap_detection_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _low_flap_threshold=$(            ${cmd_echo} ${host}  | ${cmd_jq} -r  '.flap_detection.threshold.low | if( '${_flap_detection_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _freshness_threshold=$(           ${cmd_echo} ${host}  | ${cmd_jq} -r  '.check.freshness.threshold | if( . == null ) then "" else . end' )
      _host_name=$(                     ${cmd_echo} ${host}  | ${cmd_jq} -r  '.name.string | if( . == null ) then "" else . end' )
      _hostgroups=$(                    ${cmd_echo} ${host}  | ${cmd_jq} -r  '[ .hostgroups[] | select( .enable == true ) ] | if( . | length < 1 ) then "" else join(", ") end' )
      _icon_image=$(                    ${cmd_echo} ${host}  | ${cmd_jq} -r  '.icon.file.image | if( . == null ) then "" else . end' )
      _icon_image_alt=$(                ${cmd_echo} ${host}  | ${cmd_jq} -r  '.icon.file.alternate | if( . == null ) then "" else . end' )
      _initial_state=$(                 ${cmd_echo} ${host}  | ${cmd_jq} -r  '.initial_state | if( . == null ) then "" else . end' )
      _max_check_attempts=$(            ${cmd_echo} ${host}  | ${cmd_jq} -r  '.check.max_attempts | if( . == null ) then "" else . end' )
      _notes=$(                         ${cmd_echo} ${host}  | ${cmd_jq} -r  '.notes.string | if( . == null ) then "" else . end' )
      _notes_url=$(                     ${cmd_echo} ${host}  | ${cmd_jq} -r  '.notes.url | if( . == null ) then "" else . end' )
      _notifications_enabled=$(         ${cmd_echo} ${host}  | ${cmd_jq} -r  '.notification.enable | if( . == null ) then "" else ( if( . == true ) then '${true}' else '${false}' end ) end' )
      _first_notification_delay=$(      ${cmd_echo} ${host}  | ${cmd_jq} -r  '.notification.first_delay | if( '${_notifications_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _notification_interval=$(         ${cmd_echo} ${host}  | ${cmd_jq} -r  '.notification.interval | if( '${_notifications_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _notification_options=$(          ${cmd_echo} ${host}  | ${cmd_jq} -r  '[ .notification.options | to_entries[] | select(.value == true) | .key[0:1] ] | if( '${_notifications_enabled}' == '${false}' ) then "" else ( if( . | length < 1 ) then "" else join(", ") end ) end' )
      _notification_period=$(           ${cmd_echo} ${host}  | ${cmd_jq} -r  '.notification.period | if( '${_notifications_enabled}' == '${false}' ) then "" else ( if( . == null ) then "" else . end ) end' )
      _obsess_over_host=$(              ${cmd_echo} ${host}  | ${cmd_jq} -r  '.obsess | if( . == null ) then "" else . end' )
      _parents=$(                       ${cmd_echo} ${host}  | ${cmd_jq} -r  '[ .parents[] | select( .enable == true ) ] | if( . | length < 1 ) then "" else join(", ") end' )
      _passive_checks_enabled=$(        ${cmd_echo} ${host}  | ${cmd_jq} -r  '.check.passive | if( . == null ) then "" else . end' )
      _process_perf_data=$(             ${cmd_echo} ${host}  | ${cmd_jq} -r  '.check.perfdata | if( . == null ) then "" else . end' )
      _retain_nonstatus_information=$(  ${cmd_echo} ${host}  | ${cmd_jq} -r  '.retain.nonstatus | if( . == null ) then "" else . end' )
      _retain_status_information=$(     ${cmd_echo} ${host}  | ${cmd_jq} -r  '.retain.status | if( . == null ) then "" else . end' )
      _retry_interval=$(                ${cmd_echo} ${host}  | ${cmd_jq} -r  '.check.interval.retry | if( . == null ) then "" else . end' )
      _stalking_options=$(              ${cmd_echo} ${host}  | ${cmd_jq} -r  '[ .notification.options | to_entries[] | select(.value == true) | .key[0:1] ] | if( . | length < 1 ) then "" else join(", ") end' )
      _statusmap_image=$(               ${cmd_echo} ${host}  | ${cmd_jq} -r  '.icon.file.statusmap | if( . == null ) then "" else . end' )
      _vrml_image=$(                    ${cmd_echo} ${host}  | ${cmd_jq} -r  '.icon.image.vrml | if( . == null ) then "" else . end' )


      ${cmd_echo} Writing Host: ${_path}/${_alias}.cfg
      ${cmd_cat} << EOF.host > ${_path}/${_alias}.cfg
define host                         {
  $( [[ ! -z ${_2d_coords} ]]                     && ${cmd_printf} '%-1s %-32s %-50s' "" 2d_coords "${_2d_coords}" )
  $( [[ ! -z ${_3d_coords} ]]                     && ${cmd_printf} '%-1s %-32s %-50s' "" 3d_coords "${_3d_coords}" )
  $( [[ ! -z ${_active_checks_enabled} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" active_checks_enabled "${_active_checks_enabled}" )
  $( [[ ! -z ${_action_url} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" action_url "${_action_url}" )
  $( [[ ! -z ${_address} ]]                       && ${cmd_printf} '%-1s %-32s %-50s' "" address "${_address}" )
  $( [[ ! -z ${_alias} ]]                         && ${cmd_printf} '%-1s %-32s %-50s' "" alias "${_alias}" )
  $( [[ ! -z ${_check_command} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" check_command "${_check_command}" )
  $( [[ ! -z ${_check_freshness} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" check_freshness "${_check_freshness}" )
  $( [[ ! -z ${_check_period} ]]                  && ${cmd_printf} '%-1s %-32s %-50s' "" check_period "${_check_period}" )
  $( [[ ! -z ${_check_interval} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" check_interval "${_check_interval}" )
  $( [[ ! -z ${_contact_groups} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" contact_groups "${_contact_groups}" )
  $( [[ ! -z ${_contacts} ]]                      && ${cmd_printf} '%-1s %-32s %-50s' "" contacts "${_contacts}" )
  $( [[ ! -z ${_display_name} ]]                  && ${cmd_printf} '%-1s %-32s %-50s' "" display_name "${_display_name}" )
  $( [[ ! -z ${_event_handler} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" event_handler "${_event_handler}" )
  $( [[ ! -z ${_event_handler_enabled} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" event_handler_enabled "${_event_handler_enabled}" )
  $( [[ ! -z ${_first_notification_delay} ]]      && ${cmd_printf} '%-1s %-32s %-50s' "" first_notification_delay "${_first_notification_delay}" )
  $( [[ ! -z ${_flap_detection_enabled} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" flap_detection_enabled} "${_flap_detection_enabled}}" )
  $( [[ ! -z ${_flap_detection_options} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" flap_detection_options"[${_flap_detection_options}]" )
  $( [[ ! -z ${_freshness_threshold} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" freshness_threshold "${_freshness_threshold}" )
  $( [[ ! -z ${_high_flap_threshold} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" high_flap_threshold "${_high_flap_threshold}" )
  $( [[ ! -z ${_host_name} ]]                     && ${cmd_printf} '%-1s %-32s %-50s' "" host_name"${_}" )
  $( [[ ! -z ${_hostgroups} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" hostgroups "${_hostgroups}" )
  $( [[ ! -z ${_icon_image} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" icon_image"${_icon_image}" )
  $( [[ ! -z ${_icon_image_alt} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" icon_image_alt"${_icon_image_alt}" )
  $( [[ ! -z ${_initial_state} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" initial_state "${_initial_state}" )
  $( [[ ! -z ${_low_flap_threshold} ]]            && ${cmd_printf} '%-1s %-32s %-50s' "" low_flap_threshold "${low_flap_threshold}" )
  $( [[ ! -z ${_max_check_attempts} ]]            && ${cmd_printf} '%-1s %-32s %-50s' "" max_check_attempts "${_max_check_attempts}" )
  $( [[ ! -z ${_notes} ]]                         && ${cmd_printf} '%-1s %-32s %-50s' "" notes "${_notes}" )
  $( [[ ! -z ${_notes_url} ]]                     && ${cmd_printf} '%-1s %-32s %-50s' "" notes_url "${_notes_url}" )
  $( [[ ! -z ${_notification_interval} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" notification_interval "${_notification_interval}" )
  $( [[ ! -z ${_notification_options} ]]          && ${cmd_printf} '%-1s %-32s %-50s' "" notification_options "[${_notification_options}]" )
  $( [[ ! -z ${_notification_period} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" notification_period "${_notification_period}" )
  $( [[ ! -z ${_notifications_enabled} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" notifications_enabled "${_notifications_enabled}" )
  $( [[ ! -z ${_obsess_over_host} ]]              && ${cmd_printf} '%-1s %-32s %-50s' "" obsess_over_host "${_obsess_over_host}" )
  $( [[ ! -z ${_parents} ]]                       && ${cmd_printf} '%-1s %-32s %-50s' "" parents "${_parents}" )
  $( [[ ! -z ${_passive_checks_enabled} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" passive_checks_enabled "${_passive_checks_enabled}" )
  $( [[ ! -z ${_process_perf_data} ]]             && ${cmd_printf} '%-1s %-32s %-50s' "" process_perf_data "${_process_perf_data}" )
  $( [[ ${_template} ]]                           && ${cmd_printf} '%-1s %-32s %-50s' "" register "${false}" || ${cmd_printf} '%-1s %-32s %-50s' "" register "${true}" )
  $( [[ ! -z ${_retain_nonstatus_information} ]]  && ${cmd_printf} '%-1s %-32s %-50s' "" retain_nonstatus_information "${_retain_nonstatus_information}" )
  $( [[ ! -z ${_retain_status_information} ]]     && ${cmd_printf} '%-1s %-32s %-50s' "" retain_status_information "${_retain_status_information}" )
  $( [[ ! -z ${_retry_interval} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" retry_interval "${_retry_interval}" )
  $( [[ ! -z ${_stalking_options} ]]              && ${cmd_printf} '%-1s %-32s %-50s' "" stalking_options "[${_stalking_options}]" )
  $( [[ ! -z ${_statusmap_image} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" statusmap_image "${_statusmap_image}" )
  $( [[ ! -z ${_vrml_image} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" vrml_image "${_vrml_image}" )
}
EOF.host

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