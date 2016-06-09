class apache::debian::itk inherits apache::debian {
  File['htpasswd_dir']{
    group => 0,
    mode => 0644,
  }
  Package['apache']{
    name => 'apache2-mpm-itk',
  }
}
