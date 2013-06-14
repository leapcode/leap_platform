class site_config::shell {

  file {
    '/etc/profile.d/leap_path.sh':
      content => 'PATH=$PATH:/srv/leap/bin',
      mode    => '0644',
      owner   => root,
      group   => root;
  }
}
