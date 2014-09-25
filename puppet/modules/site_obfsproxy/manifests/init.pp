class site_obfsproxy {
  tag 'leap_service'
  Class['site_config::default'] -> Class['site_obfsproxy']

  $transport = 'scramblesuit'

  $obfsproxy    = hiera('obfsproxy')
  $scramblesuit = $obfsproxy['scramblesuit']
  $scram_pass   = $scramblesuit['password']
  $scram_port   = $scramblesuit['port']
  $dest_ip      = $obfsproxy['gateway_address']
  $dest_port    = '443'

  if member($::services, 'openvpn') {
    $openvpn      = hiera('openvpn')
    $bind_address = $openvpn['gateway_address']
  }
  elsif member($::services, 'obfsproxy') {
    $bind_address = hiera('ip_address')
  }

  include site_apt::preferences::twisted
  include site_apt::preferences::obfsproxy

  class { 'obfsproxy':
    transport    => $transport,
    bind_address => $bind_address,
    port         => $scram_port,
    param        => $scram_pass,
    dest_ip      => $dest_ip,
    dest_port    => $dest_port,
  }

  include site_shorewall::obfsproxy

}



