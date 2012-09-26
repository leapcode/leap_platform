node 'default' {

  # include some basic classes
  # $concat_basedir =  '/var/lib/puppet/modules/concat'  # do we need this ?
  include concat::setup
  include apt, lsb, git
  import "common"

  $services=hiera_array('services')
  notice("Services for $fqdn: $services")

  # configure ssh and inculde ssh-keys
  #include sshd
  $ssh_keys=hiera_hash('ssh_keys')
  include site_sshd
  notice($ssh_keys)
  create_resources('site_sshd::ssh_key', $ssh_keys)


  if 'eip' in $services {
    include site_openvpn

    $tor=hiera('tor')
    notice("Tor enabled: $tor")

    $openvpn_configs=hiera('openvpn_server_configs')
    create_resources('site_openvpn::server_config', $openvpn_configs)
  }

}
