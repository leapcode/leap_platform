# ssl_mode:
#   - false: only check http
#   - true: check http and https
#   - force: http is permanent redirect to https
#   - only: check only https
define nagios::service::http(
  $ensure       = present,
  $check_domain = 'absent',
  $port     = '80',
  $check_url    = '/',
  $check_code   = '200,301,302',
  $use      = 'generic-service',
  $ssl_mode     = false
){
  $real_check_domain = $check_domain ? {
      'absent'  => $name,
      default   => $check_domain
  }
  if is_hash($check_code) {
    $check_code_hash = $check_code
  } else {
    $check_code_hash = {
      http  => $check_code,
      https => $check_code,
    }
  }
  case $ssl_mode {
    'force',true,'only': {
      nagios::service{"https_${name}":
        ensure        => $ensure,
        use           => $use,
        check_command => "check_https_url_regex!${real_check_domain}!${check_url}!'${check_code_hash[https]}'",
      }
      case $ssl_mode {
        'force': {
          nagios::service{"http_${name}":
            ensure        => $ensure,
            use           => $use,
            check_command => "check_http_url_regex!${real_check_domain}!${port}!${check_url}!'301'",
          }
        }
      }
    }
  }
  case $ssl_mode {
    false,true: {
      nagios::service{"http_${name}":
        ensure        => $ensure,
        use           => $use,
        check_command => "check_http_url_regex!${real_check_domain}!${port}!${check_url}!'${check_code_hash[http]}'",
      }
    }
  }
}
