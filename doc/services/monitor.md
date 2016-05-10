@title = "monitor"
@summary = "Nagios monitoring and continuous testing."

The `monitor` node provides a nagios control panel that will give you a view into the health and status of all the servers and all the services. It will also spam you with alerts if something goes down.

Topology
--------------------------------------

Currently, you can have zero or one `monitor` nodes defined. It is required that the monitor be on the webapp node. It was not designed to be run as a separate node service.

Configuration
-----------------------------------------------

* `nagios.environments`: By default, the monitor node will monitor all servers in all environments. You can optionally restrict the environments to the ones you specify.

For example:

    {
      "nagios": {
        "environments": ["unstable", "production"]
      }
    }

Access nagios web
-----------------------------------------------

*Determine the nagios URL*

    $ leap ls --print domain.name,webapp.domain,ip_address monitor
    > chameleon  chameleon.bitmask.net, demo.bitmask.net, 199.119.112.10

In this case, you would open `https://demo.bitmask.net/cgi-bin/nagios3` in your browser (or alternately you could use 199.119.112.10 or chameleon.bitmask.net).

*Determine the nagios password*

The username for nagios is always `nagiosadmin`. The password is randomly generated and stored in `secrets.json` under the key `nagios_admin_password`. Note that the login is `nagiosadmin` without underscore, but the entry in secrets.json is with underscores.
