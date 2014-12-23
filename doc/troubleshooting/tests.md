@title = 'Tests and Monitoring'
@summary = 'Testing and monitoring your infrastructure.'
@toc = true

## Troubleshooting Tests

At any time, you can run troubleshooting tests on the nodes of your provider infrastructure to check to see if things seem to be working correctly. If there is a problem, these tests should help you narrow down precisely where the problem is.

To run tests on FILTER node list:

    leap test run FILTER

Alternately, you can run test on all nodes (probably only useful if you have pinned the environment):

    leap test

## Monitoring

In order to set up a monitoring node, you simply add a `monitor` service tag to the node configuration file. It could be combined with any other service, but we propose that you add it to the webapp node, as this already is public accessible via HTTPS.

After deploying, this node will regularly poll every node to ask for the status of various health checks. These health checks include the checks run with `leap test`, plus many others.

We use [Nagios](http://www.nagios.org/) together with [Check MK agent](https://en.wikipedia.org/wiki/Check_MK) for running checks on remote hosts.

You can log into the monitoring web interface via [https://MONITORNODE/nagios3/](https://MONITORNODE/nagios3/). The username is `nagiosadmin` and the password is found in the secrets.json file in your provider directory.

### Log Monitoring

At the moment, we use [check-mk-agent-logwatch](https://mathias-kettner.de/checkmk_check_logwatch.html) for searching logs for irregularities.
Logs are parsed for patterns using a blacklist, and are stored in `/var/lib/check_mk/logwatch/<Nodename>`.

In order to "acknowledge" a log warning, you need to log in to the monitoring server, and delete the corresponding file in `/var/lib/check_mk/logwatch/<Nodename>`. This should be done via the nagios webinterface in the future.

