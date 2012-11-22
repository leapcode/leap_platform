class site_openvpn::keys {

  file { '/etc/openvpn/keys/ca.crt':
    content => $site_openvpn::x509_config['ca_cert'],
    mode    => '0644',
  }

  file { '/etc/openvpn/keys/dh.pem':
    content => $site_openvpn::x509_config['dh'],
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
