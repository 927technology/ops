927.ops.commands.create () {

  # local variables
  local _json=
  local _path=

  # parse command arguments
  while [[ ${1} != "" ]]; then
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
      ;;
      -p | --path )
        shift
        _path=${1}
    esac
    shift
  done


  ## main
  if [[ ! -z ${_json} ]] && [[ -d ${_path} ]]; then
    ${cmd_rm} -rf ${_path}/*
    for command in $( ${cmd_echo} ${_json}   | ${cmd_jq} -c '.commands[] | select(.enable == true)' ); do 
      _command_line=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.line' )
      _command_name=$( ${cmd_echo} ${command}| ${cmd_jq} -r '.name' )

      ${cmd_echo} Writing Command: ${_confd_path}/commands/${_command_name}.cfg
      ${cmd_cat} << EOF.command > ${_path}/${_command_name}.cfg

## these have to be left justified
define command                      {
  command_line                      ${_command_line}
  command_name                      ${_command_name}
}
EOF.command
## endl left justification

    done


    
}