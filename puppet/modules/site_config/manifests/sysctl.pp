class site_config::sysctl {

  sysctl::config {
    'net.ipv4.ip_nonlocal_bind':
      value   => 1,
      comment => 'Allow applications to bind to an address when link is down (see https://leap.se/code/issues/4506)'
  }
}
