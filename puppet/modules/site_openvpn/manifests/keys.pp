class site_openvpn::keys {

  file { '/etc/openvpn/keys/ca.key':
    content => $site_openvpn::openvpn_config['ca_key'],
    mode    => '0600',
  }

  file { '/etc/openvpn/keys/ca.crt':
    content => $site_openvpn::openvpn_config['ca_crt'],
    mode    => '0644',
  }

  file { '/etc/openvpn/keys/dh.pem':
    content => $site_openvpn::openvpn_config['dh'],
    mode    => '0644',
  }

  file { '/etc/openvpn/keys/server.key':
    content => $site_openvpn::x509_config['key'],
    mode    => '0600',
  }

  file { '/etc/openvpn/keys/server.crt':
    content => $site_openvpn::x509_config['cert'],
    mode    => '0644',
  }
}
