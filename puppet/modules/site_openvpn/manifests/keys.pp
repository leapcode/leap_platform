class site_openvpn::keys {
  $openvpn_keys = hiera_hash('openvpn')

  file { '/etc/openvpn/keys/ca.key':
    content => $openvpn_keys['ca_key'],
    mode    => '0600',
  }

  file { '/etc/openvpn/keys/ca.crt':
    content => $openvpn_keys['ca_crt'],
    mode    => '0644',
  }

  file { '/etc/openvpn/keys/dh.pem':
    content => $openvpn_keys['dh_key'],
    mode    => '0644',
  }

  file { '/etc/openvpn/keys/server.key':
    content => $openvpn_keys['server_key'],
    mode    => '0600',
  }

  file { '/etc/openvpn/keys/server.crt':
    content => $openvpn_keys['server_crt'],
    mode    => '0644',
  }
}
