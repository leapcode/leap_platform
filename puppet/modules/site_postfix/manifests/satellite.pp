class site_postfix::satellite {

  $root_mail_recipient = hiera ('contacts')
  $mail                = hiera ('mail')
  $relayhost           = $mail['smarthost']
  $cert_name           = hiera('name')

  class { '::postfix::satellite':
    relayhost           => $relayhost,
    root_mail_recipient => $root_mail_recipient
  }

  # There are special conditions for satellite hosts that will make them not be
  # able to contact their relayhost:
  #
  # 1. they are on openstack/amazon/PC and are on the same cluster as the relay
  # host, the MX lookup for the relay host will use the public IP, which cannot
  # be contacted
  #
  # 2. When a domain is used that is not in DNS, because it is internal,
  # a testing domain, etc. eg. a .local domain cannot be looked up in DNS
  #
  # to resolve this, so the satellite can contact the relayhost, we need to set
  # the http://www.postfix.org/postconf.5.html#smtp_host_lookup to be 'native'
  # which will cause the lookup to use the native naming service
  # (nsswitch.conf), which typically defaults to 'files, dns' allowing the
  # /etc/hosts to be consulted first, then DNS if the entry doesn't exist.
  #
  # NOTE: this will make it not possible to enable DANE support through DNSSEC
  # with http://www.postfix.org/postconf.5.html#smtp_dns_support_level - but
  # this parameter is not available until 2.11. If this ends up being important
  # we could also make this an optional parameter for providers without
  # dns / local domains

  postfix::config {
    'smtp_host_lookup':
      value => 'native';

    # Note: we are setting this here, instead of in site_postfix::mx::smtp_tls
    # because the mx server has to have a different value
    'smtp_tls_security_level':
      value => 'encrypt';
  }

  include site_postfix::mx::smtp_tls

}
