class site_config::shell {

  file {
    '/etc/profile.d/leap_path.sh':
      content => 'PATH=$PATH:/srv/leap/bin',
      mode    => '0644',
      owner   => root,
      group   => root;
  }

  ##
  ## XTERM TITLE
  ##

  file { '/etc/profile.d/xterm-title.sh':
    source => 'puppet:///modules/site_config/xterm-title.sh',
    owner  => root,
    group  => 0,
    mode   => '0644';
  }

}
