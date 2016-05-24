class shorewall::rules::puppet(
  $puppetserver = "puppet.${::domain}",
  $puppetserver_port = 8140,
  $puppetserver_signport = 8141
){
  shorewall::params{
    'PUPPETSERVER':             value => $puppetserver;
    'PUPPETSERVER_PORT':        value => $puppetserver_port;
    'PUPPETSERVER_SIGN_PORT':   value => $puppetserver_signport;
  }
}
