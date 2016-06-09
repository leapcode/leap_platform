class nagios::nrpe::linux inherits nagios::nrpe::base {

    package {
        "nagios-plugins-standard": ensure => present;
        "ksh": ensure => present; # for check_cpustats.sh
        "sysstat": ensure => present; # for check_cpustats.sh
    }

}
