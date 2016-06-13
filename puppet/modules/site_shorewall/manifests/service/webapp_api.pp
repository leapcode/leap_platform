# configure shorewall for webapp api
class site_shorewall::service::webapp_api {

  $api = hiera('api')
  $api_port = $api['port']

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_webapp_api':
    content => "PARAM   -       -       tcp    ${api_port} ",
    notify  => Exec['shorewall_check'],
    require => Package['shorewall']
  }


  shorewall::rule {
      'net2fw-webapp_api':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_webapp_api(ACCEPT)',
        order       => 200;
  }

}
