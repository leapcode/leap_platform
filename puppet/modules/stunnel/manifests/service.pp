define stunnel::service (
  $ensure = present,
  $accept = false,
  $capath = false,
  $cafile = false,
  $cert = false,
  $chroot = false,
  $ciphers = false,
  $client = false,
  $compress = false,
  $connect = false,
  $crlpath = false,
  $crlfile = false,
  $debuglevel = false,
  $delay = false,
  $egd = false,
  $engine = false,
  $engineCtrl = false,
  $enginenum = false,
  $exec = false,
  $execargs = false,
  $failover = false,
  $ident = false,
  $key = false,
  $local = false,
  $oscp = false,
  $ocspflag = false,
  $options = false,
  $output = false,
  $pid = false,
  $protocol = false,
  $protocolauthentication = false,
  $protocolhost = false,
  $protocolpassword = false,
  $protocolusername = false,
  $pty = false,
  $retry = false,
  $rndbytes = false,
  $rndfile = false,
  $rndoverwrite = false,
  $service = false,
  $session = false,
  $setuid = 'stunnel4',
  $setgid = 'stunnel4',
  $socket = [ 'l:TCP_NODELAY=1', 'r:TCP_NODELAY=1'],
  $sslversion = 'SSLv3',
  $stack = false,
  $syslog = false,
  $timeoutbusy = false,
  $timeoutclose = false,
  $timeoutconnect = false,
  $timeoutidle = false,
  $transparent = false,
  $manage_nagios = false,
  $verify = false
) {

  include stunnel

  $real_client = $client ? { default => 'yes' }
  $real_pid = $pid ? { false => "/${name}.pid", default => $pid }

  $stunnel_compdir = "${::puppet_vardir}/stunnel4/configs"

  file {
    "${stunnel_compdir}/${name}.conf":
      ensure  => $ensure,
      content => template('stunnel/service.conf.erb'),
      require => Package['stunnel'],
      notify  => Exec['refresh_stunnel'],
      owner   => 'root',
      group   => 0,
      mode    => '0600';
  }

  if $manage_nagios {
    stunnel::service::nagios { $name: }
  }
}
