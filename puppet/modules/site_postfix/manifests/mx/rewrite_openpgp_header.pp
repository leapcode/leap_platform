class site_postfix::mx::rewrite_openpgp_header {
  $mx             = hiera('mx')
  $correct_domain = $mx['key_lookup_domain']

  file { '/etc/postfix/checks/rewrite_openpgp_headers':
    content => template('site_postfix/checks/rewrite_openpgp_headers.erb'),
    mode    => '0644',
    owner   => root,
    group   => root;
  }
}
