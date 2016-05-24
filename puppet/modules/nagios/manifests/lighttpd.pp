class nagios::lighttpd(
  $allow_external_cmd = false,
  $manage_shorewall = false,
  $manage_munin = false
) {
  class{'nagios':
    httpd => 'lighttpd',
    allow_external_cmd => $allow_external_cmd,
    manage_munin => $manage_munin,
    manage_shorewall => $manage_shorewall,
  }
}
