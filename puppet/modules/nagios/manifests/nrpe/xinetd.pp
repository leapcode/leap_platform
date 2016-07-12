# This is created only to cope with cases where we're not the only ones
# administering a machine and NRPE is running in xinetd.
class nagios::nrpe::xinetd inherits base {

    Service["nagios-nrpe-server"] {
	    ensure    => stopped,
    }

    # TODO manage the xinetd config file that glues with NRPE

}
