# hidden services definition
define tor::daemon::hidden_service(
  $ports         = [],
  $single_hop    = false,
  $v3            = false,
  $data_dir      = $tor::daemon::data_dir,
  $ensure        = present ) {


  if $single_hop {
    file { "${$data_dir}/${$name}/onion_service_non_anonymous":
      ensure => 'present',
    }
  }

  concat::fragment { "05.hidden_service.${name}":
    ensure  => $ensure,
    content => template('tor/torrc.hidden_service.erb'),
    order   => 05,
    target  => $tor::daemon::config_file,
  }
}
