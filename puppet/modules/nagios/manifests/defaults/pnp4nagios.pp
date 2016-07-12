# configure default cmds for pnp4nagios
class nagios::defaults::pnp4nagios {

  # performance data cmds
    # http://docs.pnp4nagios.org/de/pnp-0.6/config#bulk_mode_mit_npcd
    nagios_command {
        'process-service-perfdata-file-pnp4nagios-bulk-npcd':
            command_line => '/bin/mv /var/lib/nagios3/service-perfdata /var/spool/pnp4nagios/npcd/service-perfdata.$TIMET$',
            require      => Package['nagios'];
        'process-host-perfdata-file-pnp4nagios-bulk-npcd':
            command_line => '/bin/mv /var/lib/nagios3/host-perfdata /var/spool/pnp4nagios/npcd/host-perfdata.$TIMET$',
            require      => Package['nagios'];
    }
}
