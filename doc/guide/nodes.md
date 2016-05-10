@title = "Nodes"
@summary = "Working with nodes, services, tags, and locations."

Locations
================================

All nodes should have a `location.name` specified, and optionally additional information about the location, like the time zone. This location information is used for two things:

* Determine which nodes can, or must, communicate with one another via a local network. The way some virtualization environments work, like OpenStack, requires that nodes communicate via the local network if they are on the same network.
* Allows the client to prefer connections to nodes that are closer in physical proximity to the user. This is particularly important for OpenVPN nodes.

The location stanza in a node's config file looks like this:

    {
      "location": {
        "id": "ankara",
        "name": "Ankara",
        "country_code": "TR",
        "timezone": "+2",
        "hemisphere": "N"
      }
    }

The fields:

* `id`: An internal handle to use for this location. If two nodes have match `location.id`, then they are treated as being on a local network with one another. This value defaults to downcase and underscore of `location.name`.
* `name`: Can be anything, might be displayed to the user in the client if they choose to manually select a gateway.
* `country_code`: The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1) two letter country code.
* `timezone`: The timezone expressed as an offset from UTC (in standard time, not daylight savings). You can look up the timezone using this [handy map](http://www.timeanddate.com/time/map/).
* `hemisphere`: This should be "S" for all servers in South America, Africa, or Australia. Otherwise, this should be "N".

These location options are very imprecise, but good enough for most usage. The client often does not know its own location precisely either. Instead, the client makes an educated guess at location based on the OS's timezone and locale.

If you have multiple nodes in a single location, it is best to use a tag for the location. For example:

`tags/ankara.json`:

    {
      "location": {
        "name": "Ankara",
        "country_code": "TR",
        "timezone": "+2",
        "hemisphere": "N"
      }
    }

`nodes/vpngateway.json`:

    {
      "services": "openvpn",
      "tags": ["production", "ankara"],
      "ip_address": "1.1.1.1",
      "openvpn": {
        "gateway_address": "1.1.1.2"
      }
    }

Unless you are using OpenStack or AWS, setting `location` for nodes is not required. It is, however, highly recommended.

Disabling Nodes
=====================================

There are two ways to temporarily disable a node:

**Option 1: disabled environment**

You can assign an environment to the node that marks it as disabled. Then, if you use environment pinning, the node will be ignored when you deploy. For example:

    {
      "environment": "disabled"
    }

Then use `leap env pin ENV` to pin the environment to something other than 'disabled'. This only works if all the other nodes are also assigned to some environment.

**Option 2: enabled == false**

If a node has a property `enabled` set to false, then the `leap` command will skip over the node and pretend that it does not exist. For example:

    {
      "ip_address": "1.1.1.1",
      "services": ["openvpn"],
      "enabled": false
    }

**Options 3: no-deploy**

If the file `/etc/leap/no-deploy` exists on a node, then when you run the commmand `leap deploy` it will halt and prevent a deploy from going through (if the node was going to be included in the deploy).
