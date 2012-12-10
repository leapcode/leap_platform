class site_openvpn::keys {

  x509::key {
    'leap_openvpn':
      content => $site_openvpn::x509_config['key'],
      notify  => Service[openvpn];
  }

  x509::cert {
    'leap_openvpn':
      content => $site_openvpn::x509_config['cert'],
      notify  => Service[openvpn];
  }

  x509::ca {
    'leap_openvpn':
      content => $site_openvpn::x509_config['ca_cert'],
      notify  => Service[openvpn];
  }

  file { '/etc/openvpn/keys/dh.pem':
    content => $site_openvpn::x509_config['dh'],
    mode    => '0644',
  }

}
