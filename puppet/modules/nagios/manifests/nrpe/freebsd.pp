class nagios::nrpe::freebsd inherits nagios::nrpe::base {

    Package["nagios-nrpe-server"] { name => "nrpe" }
    Package["nagios-plugins-basic"] { name => "nagios-plugins" }
    Package["libnagios-plugin-perl"] { name => "p5-Nagios-Plugin" }
    Package["libwww-perl"] { name => "p5-libwww" }

    # TODO check_cpustats.sh is probably not working as of now. the package 'sysstat' is not available under FreeBSD

    Service["nagios-nrpe-server"] {
        pattern => "^/usr/local/sbin/nrpe2",
        path => "/usr/local/etc/rc.d",
        name => "nrpe2",
	hasstatus => "false",
    }
}
