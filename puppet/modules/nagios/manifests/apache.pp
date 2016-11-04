# setup naguis together with apache
class nagios::apache(
  $allow_external_cmd = false,
  $manage_shorewall = false,
  $manage_munin = false,
  $storeconfigs = true
) {
  class{'::nagios':
    httpd              => 'apache',
    allow_external_cmd => $allow_external_cmd,
    manage_munin       => $manage_munin,
    manage_shorewall   => $manage_shorewall,
    storeconfigs       => $storeconfigs
  }
}
