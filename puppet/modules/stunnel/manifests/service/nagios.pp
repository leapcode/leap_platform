# Put a Nagios service check in place for a specific tunnel.
#
# The resource name will be used to point to the corresponding stunnel
# configuration file.
#
define stunnel::service::nagios () {

    nagios::service { "stunnel_${name}":
      check_command => "nagios-stat-proc!/usr/bin/stunnel4 /etc/stunnel/${name}.conf!6!5!proc";
    }

}
