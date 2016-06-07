@title = 'Tests and Monitoring'
@summary = 'Testing and monitoring your infrastructure.'
@toc = true

## Troubleshooting Tests

At any time, you can run troubleshooting tests on the nodes of your provider infrastructure to check to see if things seem to be working correctly. If there is a problem, these tests should help you narrow down precisely where the problem is.

To run tests on FILTER node list:

    workstation$ leap test run FILTER

For example, you can also test a single node (`leap test elephant`); test a specific environment (`leap test development`), or any tag (`leap test soledad`).

Alternately, you can run test on all nodes (probably only useful if you have pinned the environment):

    workstation$ leap test

The tests that are performed are located in the platform under the tests directory.

## Testing with the bitmask client

Download the provider ca:

    wget --no-check-certificate https://example.org/ca.crt -O /tmp/ca.crt

Start bitmask:

    bitmask --ca-cert-file /tmp/ca.crt

## Testing Recieving Mail

Use i.e. swaks to send a testmail

    swaks -f noone@example.org -t testuser@example.org -s example.org

and use your favorite mail client to examine your inbox.

You can also use [offlineimap](http://offlineimap.org/) to fetch mails:

     offlineimap -c vagrant/.offlineimaprc.example.org

WARNING: Use offlineimap *only* for testing/debugging,
because it will save the mails *decrypted* locally to
your disk !

## Monitoring

In order to set up a monitoring node, you simply add a `monitor` service tag to the node configuration file. It could be combined with any other service, but we propose that you add it to the webapp node, as this already is public accessible via HTTPS.

After deploying, this node will regularly poll every node to ask for the status of various health checks. These health checks include the checks run with `leap test`, plus many others.

We use [Nagios](https://www.nagios.org/) together with [Check MK agent](https://en.wikipedia.org/wiki/Check_MK) for running checks on remote hosts.

One nagios installation will monitor all nodes in all your environments. You can log into the monitoring web interface via [https://DOMAIN/nagios3/](https://DOMAIN/nagios3/). The username is `nagiosadmin` and the password is found in the secrets.json file in your provider directory.
Nagios will send out mails to the `contacts` address provided in `provider.json`.


## Nagios Frontends

There are other ways to check and get notified by Nagios besides regularly checking the Nagios webinterface or reading email notifications. Check out the [Frontends (GUIs and CLIs)](http://exchange.nagios.org/directory/Addons/Frontends-%28GUIs-and-CLIs%29) on the Nagios project website.
A recommended status tray application is [Nagstamon](https://nagstamon.ifw-dresden.de/), which is available for Linux, MacOS X and Windows. It can not only notify you of hosts/services failures, you can also acknowledge or recheck them.

### Log Monitoring

At the moment, we use [check-mk-agent-logwatch](https://mathias-kettner.de/checkmk_check_logwatch.html) for searching logs for irregularities.
Logs are parsed for patterns using a blacklist, and are stored in `/var/lib/check_mk/logwatch/<Nodename>`.

In order to "acknowledge" a log warning, you need to log in to the monitoring server, and delete the corresponding file in `/var/lib/check_mk/logwatch/<Nodename>`. This should be done via the nagios webinterface in the future.

