class nagios::nrpe::debian inherits nagios::nrpe::base {
  include nagios::nrpe::linux
  Service['nagios-nrpe-server'] {
    hasstatus => false,
  }
}
