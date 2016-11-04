# enables a systemd resource
define systemd::enable () {

  exec { "enable_systemd_${name}":
    refreshonly => true,
    command     => "/bin/systemctl enable ${name}"
  }
}
