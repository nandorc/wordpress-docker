# Set recommended configurations
ini_file_dir=/etc/php/7.4/apache2/php.ini
[ ! -f "${ini_file_dir}" ] && echo -e "ERR~ Can't find php.ini file to set recommended configurations" && exit 1
settings=("date.timezone=America/Bogota" "max_execution_time=120" "memory_limit=2G" "post_max_size=64M" "upload_max_filesize=64M" "max_input_time=60" "max_input_vars=3000" "realpath_cache_size=10M" "realpath_cache_ttl=7200" "opcache.save_comments=1")
for setting in "${settings[@]}"; do
  setting=(${setting//=/ })
  current_value=$(cat "${ini_file_dir}" | grep "^${setting[0]}")
  if [ -n "${current_value}" ]; then
    current_value=(${current_value//=/ }) && current_value=${current_value[1]}
    [ "${current_value}" == "${setting[1]}" ] && echo -e "INF~ ${setting[0]} is already setted to ${setting[1]}" && continue
    sed -i -e "s|^${setting[0]}\(.*\)|${setting[0]} = ${setting[1]}|" "${ini_file_dir}"
    res_cod=$?
  else
    current_value=$(cat "${ini_file_dir}" | grep "^;${setting[0]}")
    [ -z "${current_value}" ] && echo -e "ERR~ Can't find ${setting[0]} to set it as ${setting[1]}" && exit 1
    sed -i -e "s|^;${setting[0]}\(.*\)|${setting[0]} = ${setting[1]}|" "${ini_file_dir}"
    res_cod=$?
  fi
  [ ${res_cod} -eq 0 ] && echo -e "INF~ ${setting[0]} was settet to ${setting[1]}" && continue
  echo -e "WRN~ Couldn't set ${setting[0]} to ${setting[1]}" && exit 1
done
exit 0
